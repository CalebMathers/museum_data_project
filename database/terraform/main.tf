provider "aws" {
    region = var.AWS_REGION
    access_key = var.AWS_ACCESS_KEY
    secret_key = var.AWS_SECRET_KEY
}

data "aws_db_subnet_group" "public_subnet_group" {
    name = var.AWS_SUBNET_GROUP
}

data "aws_vpc" "vpc" {
    id = var.AWS_VPC_ID
}

resource "aws_security_group" "museum-db-sg" {
    name = var.AWS_SG_NAME
    vpc_id = data.aws_vpc.vpc.id

    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_db_instance" "museum-db" {
    allocated_storage = 10
    db_name = "museum"
    identifier = var.AWS_RDS_NAME
    engine = "postgres"
    engine_version = "16.1"
    instance_class = "db.t3.micro"
    publicly_accessible = true
    performance_insights_enabled = false
    skip_final_snapshot = true
    db_subnet_group_name = data.aws_db_subnet_group.public_subnet_group.name
    vpc_security_group_ids = [aws_security_group.museum-db-sg.id]
    username = var.DB_USERNAME
    password = var.DB_PASSWORD
}
