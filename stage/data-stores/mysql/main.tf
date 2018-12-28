terraform {
  required_version = ">= 0.8, < 0.9"
}

provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_db_instance" "example" {
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  name                = "example_database"
  username            = "admin"
  password            = "${var.db_password}"
  skip_final_snapshot = true
}
