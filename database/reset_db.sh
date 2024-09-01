source .env
psql -h $DB_HOST -p 5432 -U $DB_USER museum -f "schema.sql"