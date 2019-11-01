terraform {
  required_version = "~> 0.12.01"

  backend "s3" {
    encrypt = true
    bucket  = "rfrancisco-aws-arch-tfstate"
    region  = "us-east-1"
    key     = "awsarchitecture/labone"
  }
}

provider "aws" {
  version    = "~> 2.9"
  region     = "${var.region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

#data "template_file" "bucket_policy" {
#  template = "${file("${path.module}/policy/bucket_policy.json")}"
#
#  vars = {
#    bucket_name = "${var.web_bucket_name}"
#  }
#}

resource "aws_s3_bucket" "web_bucket" {
  bucket = "${var.web_bucket_name}"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }

  tags = {
    Name       = "AWS Architecture Lab 1"
    Department = "Marketing"
  }
}

resource "aws_s3_bucket_object" "index_file" {
  bucket = "${aws_s3_bucket.web_bucket.id}"
  acl    = "public-read"
  key    = "index.html"
  source = "../index.html"
  etag   = "${filemd5("../index.html")}"
}

resource "aws_s3_bucket_object" "script_file" {
  bucket = "${aws_s3_bucket.web_bucket.id}"
  acl    = "public-read"
  key    = "script.js"
  source = "../script.js"
  etag   = "${filemd5("../script.js")}"
}

resource "aws_s3_bucket_object" "css_file" {
  bucket = "${aws_s3_bucket.web_bucket.id}"
  acl    = "public-read"
  key    = "style.css"
  source = "../style.css"
  etag   = "${filemd5("../style.css")}"
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = "${aws_s3_bucket.web_bucket.id}"

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
