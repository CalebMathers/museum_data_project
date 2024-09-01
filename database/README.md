# Dashboard

This folder houses any files or directories associated with the setting up of the database.

## Folders

- `terraform`
    - This folder contains the terraform files used to create an RDS database on Amazon Web Service.

## Files

- `README.md`
    - This is the current file you are reading, with instructions on how to use the files inside this directory.
- `schema.sql`
    - This contains the SQL to set up a Postgres database for the museum.
- `reset_db.sh`
    - This is a short bash script that will use the values from a `.env` to create or reset the database.

## Usage

### To host on an RDS

1. Navigate into the terraform directory.
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
5. Return to the database directory and create a file called `.env`, inside this file enter the following variables:
    - Format: `KEY_NAME=key_value`
    - `DB_HOST` - This is the DB address that was given as output from the `terraform apply`.
    - `DB_USER` - The username for the RDS, should be the same as the `DB_USERNAME` from `terraform.tfvars`.
6. In the terminal, use `bash reset_db.sh`, this will create the initial database tables and fill in any static data.
    - This script can be run again if you wish to reset the database to it's original state.

### To host locally

1. In the terminal, use `psql postgres -c "CREATE DATABASE museum;"`, this will create the database.
2. In the terminal, use `psql postgres -f "schema.sql"`, this will create the initial database tables and fill in any static data.
    - This command can also be run again if you wish to reset the database to it's original state.

#### The database is now ready for the data to come in.