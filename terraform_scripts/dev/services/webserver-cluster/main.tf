provider "aws" {
  region = "us-west-2"
}

data "terraform_remote_state" "db" {

  backend = "s3"

  config {
    bucket = "prepdigi-tf-state-s3"
    key = "dev/data-stores/mysql/terraform.tfstate"
    region = "us-west-2"
  }

}


resource "aws_security_group" "instance" {
  name ="tf-sample-sg"

  ingress {
    from_port = "${var.web_server_port}"
    to_port = "${var.web_server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "tf-sample-ec2-lc" {

  image_id           = "ami-e580c79d"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              sudo echo "Hello, world from dynamic environment" > index.html
              sudo echo "${data.terraform_remote_state.db.backend}" >>index.html
              sudo nohup busybox httpd -f -p "${var.web_server_port}" &
              EOF



  lifecycle {
    create_before_destroy = true
  }


}


data "aws_availability_zones" "all" {}

resource "aws_autoscaling_group" "tf-sample-ec2-ASG" {
  launch_configuration = "${aws_launch_configuration.tf-sample-ec2-lc.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  load_balancers = ["${aws_elb.tf-sample-elb.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 5

  tag {
    key = "Name"
    value = "tf-sample-ASG"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "elb-sg" {
  name = "tf-sample-elb-sg"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "tf-sample-elb" {

  name = "tf-sample-elb-asg"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  security_groups = ["${aws_security_group.elb-sg.id}"]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "${var.web_server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:${var.web_server_port}/"
  }
}