
output "s3_bucket_arn" {
  value = "${aws_s3_bucket.tf_state_s3.arn}"
}