
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

}

resource "aws_instance" "tf-sample-ec2" {

  ami           = "ami-e580c79d"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  
  user_data = <<-EOF
              #!/bin/bash
              sudo echo "Hello, world from dynamic environment" > index.html
              sudo nohup busybox httpd -f -p "${var.web_server_port}" &
              EOF

  tags {
  	Name = "tf-sample-ubuntu-1"
  }
  
  
}

output "public_ip" {
    value = "${aws_instance.tf-sample-ec2.public_ip}"
}