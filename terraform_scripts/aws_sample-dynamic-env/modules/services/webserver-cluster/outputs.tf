output "public_ip" {
  value = "${aws_elb.tf-sample-elb.dns_name}"
}
