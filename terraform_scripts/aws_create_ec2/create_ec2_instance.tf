
resource "aws_security_group" "instance" {
  name ="tf-sample-sg"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
resource "aws_instance" "aws_image" {

  ami           = "ami-32d8124a"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  
  user_data = <<-EOF
              #!/bin/bash
              sudo echo "Hello, world from dynamic environment" > index.html
              sudo nohup busybox httpd -f -p 8080 &
              EOF

  tags {
  	Name = "tf-sample-1"
  }
  
}