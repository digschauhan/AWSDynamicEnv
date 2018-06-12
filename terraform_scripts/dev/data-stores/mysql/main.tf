
provider "aws" {
  region = "us-west-2"
}

resource "aws_db_instance" "sampledb" {
  instance_class = "db.t2.micro"
  engine = "mysql"
  allocated_storage = 10
  name = "sample_database"
  username = "admin"
  password = "${var.db_password}"

}