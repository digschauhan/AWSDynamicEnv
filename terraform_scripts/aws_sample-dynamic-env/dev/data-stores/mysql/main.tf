
provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket = "prepdigi-tf-state-s3"
    key    = "dev/data-stores/mysql/terraform.tfstate"
    region = "us-west-2"
  }
}

resource "aws_db_instance" "sampledb" {
  instance_class = "db.t2.micro"
  engine = "mysql"
  allocated_storage = 10
  name = "sample_database"
  username = "admin"
  password = "${var.db_password}"
  skip_final_snapshot = true

}