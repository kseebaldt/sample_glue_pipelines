terraform {
  required_version = "~> 1.2.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.30.0"
    }
  }
}

resource "aws_s3_bucket" "data" {
  bucket = "${var.app_prefix}-data"
}

resource "aws_s3_bucket_acl" "data" {
  bucket = aws_s3_bucket.data.id
  acl    = "private"
}