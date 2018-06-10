
provider "aws" {
  region = "us-west-2"
}

variable "web_server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
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
              sudo nohup busybox httpd -f -p "${var.web_server_port}" &
              EOF

  

  lifecycle {
    create_before_destroy = true
  }
  
  
}

output "public_ip" {
    value = "${aws_launch_configuration.tf-sample-ec2-lc.public_ip}"
}

data "aws_availability_zones" "all" {}

resource "aws_autoscaling_group" "tf-sample-ec2-ASG" {
  launch_configuration = "${aws_launch_configuration.tf-sample-ec2-lc.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  
  min_size = 2
  max_size = 5

  tag {
    key = "Name"
    value = "tf-sample-ASG"
    propagate_at_launch = true
  }
}