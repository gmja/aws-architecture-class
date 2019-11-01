terraform {
  required_version = "~> 0.12.01"

  backend "s3" {
    encrypt = true
    bucket  = "rfrancisco-aws-arch-tfstate"
    region  = "us-east-1"
    key     = "awsarchitecture/labtwo"
  }
}

provider "aws" {
  version    = "~> 2.9"
  region     = "${var.region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

