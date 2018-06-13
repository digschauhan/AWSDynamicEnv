
provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "tf_state_s3" {
  bucket = "prepdigi-tf-state-s3"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }

}