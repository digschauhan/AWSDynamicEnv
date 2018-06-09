resource "aws_instance" "aws_image" {

  ami           = "ami-32d8124a"
  instance_type = "t2.micro"
  
  tags {
  	Name = "tf-sample"
  }
  
}