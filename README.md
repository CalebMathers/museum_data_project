# Museum Data Pipeline

This project was created to take live museum feedback kiosk data from a Kafka stream and upload it to a database. The feedback kiosks were placed at each exhibition and visitors could select a rating from 0(bad) to 4(great) or choose to request assistance, or help in an emergency.

## Project status

The project is finished, however the Kafka stream that was initially used is no longer available and without a specific stream of data the project is unlikely to run correctly.

## Required

- `python3`
- `pip`
- `postgresql`
- `terraform` (Optional)
- `AWS` (Optional)

## Usage instructions

- Before you start, download all the project files.

### Setting up the database

#### To host on an RDS

1. Navigate into `/database/terraform`.
2. In the terminal, use `terraform init` to set up terraform.
2. Create a file called `terraform.tfvars`, inside this file enter the following variables:
    - Format: `KEY_NAME = "key_value"`
    - `AWS_ACCESS_KEY` - Your AWS access key.
    - `AWS_SECRET_KEY` - Your AWS secret key.
    - `DB_USERNAME` - The username you will use for the RDS.
    - `DB_PASSWORD` - The password you will use for the RDS.
    - `AWS_REGION` - (Optional -> Default "eu-west-2") The AWS region you want to host the RDS.
    - `AWS_SUBNET_GROUP` - The AWS subnet group you wish to use.
    - `AWS_VPC_ID` - The ID of the AWS VPC you wish to use.
    - `AWS_SG_NAME` - The name you wish to use for the RDS security group.
    - `AWS_RDS_NAME` - The name you wish the RDS to be identified by.
4. In the terminal, use `terraform apply` to create the AWS RDS; this will take a few minutes.
    - Once the RDS has been created, you should see an output of your DB address, make note of this.
5. Return to `/database` and create a file called `.env`, inside this file enter the following variables:
    - Format: `KEY_NAME=key_value`.
    - `DB_HOST` - This is the DB address that was given as output from the `terraform apply`.
    - `DB_USER` - The username for the RDS, should be the same as the `DB_USERNAME` from `terraform.tfvars`.
6. In the terminal, use `bash reset_db.sh`, this will create the initial database tables and fill in any static data.
    - This script can be run again if you wish to reset the database to it's original state.

#### To host locally

1. In the terminal, use `psql postgres -c "CREATE DATABASE museum;"`, this will create the database.
2. In the terminal, use `psql postgres -f "schema.sql"`, this will create the initial database tables and fill in any static data.
    - This command can also be run again if you wish to reset the database to it's original state.

- The database is now ready for the data to come in.

### Running the pipeline

- If you would like to run the script on an EC2 instance, create an appropriate EC2 instance, clone the repo onto it and install the necessary requirements, then follow the instructions below.

1. In the terminal, use `pip3 install -r requirements.txt` to install the required libraries.
2. Navigate to `/pipeline` and create a file called `.env`, inside this file enter the following variables:
    - Format: `KEY_NAME=key_value`.
    - `BOOTSTRAP_SERVERS` - The Kafka server to connect to.
    - `SECURITY_PROTOCOL` - The security protocol for the Kafka stream.
    - `SASL_MECHANISM` - The mechanism for the chose security protocol.
    - `USERNAME` - The username for the consumer.
    - `PASSWORD` - The password for the consumer.
    - `KAFKA_GROUP_ID` - The group ID for the consumer.
    - `SUBSCRIBE` - The name of the Kafka stream to subscribe to.
    - `DB_NAME` - The name of the database.
    - `DB_USER` - The username for the database.
    - `DB_PASSWORD` - The password for the database.
    - `DB_HOST` - The host location of the database.
3. Still in the `/pipeline` directory; in the terminal, use `python3 consume_and_upload.py` to run the Python script.
    - Available options: 
        - `--log` or `-l` - If used when running the file, any invalid messages will be logged to a file `consumer.log`.
    - You could also run the script as a background task if you wish.

- The script is now running and uploading any valid messages form the Kafka stream to the database. To stop the script use `ctrl + c` or if it is running as a background task find the PID and kill it.

## Folders and files

- `README.md` - The current file you are reading, documentation for the project.
- `.gitignore` - File that tells git what to ignore.
- `requirements.txt` - Text file that lists the required python libraries for the project.
- `dashboard` - Contains examples of a dashboard that could be created from the data.
    - `museum_dashboard_wireframe.png` - A wireframe depicting the layout of a dashboard.
    - `museum_dashboard.png` - A screenshot of a dashboard I created on Tableau.
- `database` - Contains the files for initialising the museum database.
    - `terraform` - Contains the files for terraforming an Amazon Web Service (AWS) RDS.
        - `main.tf` - The main terraform file to run.
        - `outputs.tf` - Describes the outputs to produce after `main.tf` is run.
        - `variables.tf` - Describes the variables to be used in `main.tf`.
    - `schema.sql` - This contains the SQL to set up a Postgres database for the museum.
    - `reset_db.sh` - This is a short bash script that will use the values from a `.env` to create or reset the database.
- `pipeline` - Contains the files for running the data pipeline.
    - `consume_and_upload.py` - Python script that takes data from a Kafka stream, validates it, and uploads to the database.

## License

[MIT](https://choosealicense.com/licenses/mit/)
