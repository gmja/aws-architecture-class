variable "region" {
  description = "The name of the AWS region to create resources in"
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "Access key to use with AWS provider"
  default     = "AKIA2VFJSCGXHWMPW7AT"
}

variable "aws_secret_key" {
  description = "Secret key to use with AWS provider"
  default     = "aw4JH2ko60o8tDsVg/n8BLuh54DMvBhm4s4l2uL7"
}

variable "web_bucket_name" {
  description = "The name of the web bucket to create"
  default     = "francisco-rod-aws-arch-labone-web"
}

variable "site_name" {
  description = "The DNS domain name of the web site"
  default     = "francisco"
}
