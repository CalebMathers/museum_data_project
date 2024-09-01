"""File for the consumption of a Kafka data stream"""

from os import environ as ENV
import json
from datetime import datetime
import logging
from argparse import ArgumentParser
from psycopg2 import connect, extensions, extras
from confluent_kafka import Consumer
from dotenv import load_dotenv


def check_incoming_data(data: dict) -> dict:
    """Takes a line of data and checks if it fits the correct values"""
    if not all(key in ["at", "site", "val", "type"] for key in data.keys()):
        return {"error": True, "message": "Invalid keys"}

    try:
        data_time = datetime.strptime(
            data.get("at"), "%Y-%m-%dT%H:%M:%S.%f%z").time()
    except TypeError:
        return {"error": True, "message": "Invalid 'at'; must be in format %Y-%m-%dT%H:%M:%S.%f%z"}

    start_time = datetime.strptime("08:45:00", "%H:%M:%S").time()
    end_time = datetime.strptime("18:15:00", "%H:%M:%S").time()

    if not start_time < data_time < end_time:
        return {"error": True, "message": "Invalid time; must be between 0845 and 1815."}

    if not data.get("site") in ["0", "1", "2", "3", "4", "5"]:
        return {"error": True, "message": "Invalid site; must be 0 to 5 inclusive."}

    if not data.get("val") in list(range(-1, 5)):
        return {"error": True, "message": "Invalid value; must be -1 to 4 inclusive."}

    if data["val"] == -1 and not data.get("type") in [0, 1]:
        return {"error": True, "message": "Invalid type; if 'val' is -1, 'type' must be 0 or 1."}

    return data


def create_option() -> bool:
    """Sets the command line options"""
    parser = ArgumentParser()
    parser.add_argument("--log", "-l", action="store_true")

    options = parser.parse_args()

    return options.log


def create_logger(file_logger: bool) -> logging.Logger:
    """Creates a logger"""
    logger = logging.getLogger("consumer")

    if file_logger:
        logging.basicConfig(filename="consumer.log",
                            encoding="utf-8", level=logging.INFO)
    else:
        logging.basicConfig(encoding="utf-8", level=logging.INFO)

    return logger


def create_consumer() -> Consumer:
    """Connects to a kafka stream and returns a consumer"""
    load_dotenv()

    kafka_config = {
        "bootstrap.servers": ENV["BOOTSTRAP_SERVERS"],
        "security.protocol": ENV["SECURITY_PROTOCOL"],
        "sasl.mechanisms": ENV["SASL_MECHANISM"],
        "sasl.username": ENV["USERNAME"],
        "sasl.password": ENV["PASSWORD"],
        "group.id": ENV["KAFKA_GROUP_ID"],
        "auto.offset.reset": "earliest"
    }

    kafka_consumer = Consumer(kafka_config)
    kafka_consumer.subscribe([ENV["SUBSCRIBE"]])

    return kafka_consumer


def consume_and_upload(kafka_consumer: Consumer, log: logging.Logger,
                       connection: extensions.connection) -> None:
    """Consumes data from a Kafka stream and uploads it to the database"""
    while True:
        message = kafka_consumer.poll(1.0)
        if message:
            message = json.loads(message.value().decode("utf-8"))
            check_message = check_incoming_data(message)
            if check_message.get("error"):
                check_message["original_message"] = message
                log.warning(check_message)
            elif check_message["val"] == -1:
                upload_request(message, connection)
            else:
                upload_rating(message, connection)


def upload_request(data: dict, connection: extensions.connection) -> None:
    """Uploads a new row to request interaction"""
    query = "INSERT INTO request_interaction (exhibition_id, request_id, event_at) VALUES %s;"
    values = (int(data["site"]), int(data["type"]), data["at"])

    with get_cursor(connection) as cur:
        cur.execute(query, (values, ))
        connection.commit()


def upload_rating(data: dict, connection: extensions.connection) -> None:
    """Uploads a new row to rating interaction"""
    query = "INSERT INTO rating_interaction (exhibition_id, rating_id, event_at) VALUES %s;"
    values = (int(data["site"]), int(data["val"]), data["at"])

    with get_cursor(connection) as cur:
        cur.execute(query, (values, ))
        connection.commit()


def get_database_connection() -> extensions.connection:
    """Creates a database connection with necessary params."""
    load_dotenv()

    return connect(dbname=ENV["DB_NAME"],
                   host=ENV["DB_HOST"],
                   user=ENV["DB_USER"],
                   password=ENV["DB_PASSWORD"])


def get_cursor(connection: extensions.connection) -> extensions.cursor:
    """Creates a cursor using the passed in connection."""
    return connection.cursor(cursor_factory=extras.RealDictCursor)


if __name__ == "__main__":
    logger_file = create_option()
    consumer_logs = create_logger(logger_file)
    consumer = create_consumer()

    with get_database_connection() as conn:
        try:
            consume_and_upload(consumer, consumer_logs, conn)
        except KeyboardInterrupt:
            print("Interrupted")
