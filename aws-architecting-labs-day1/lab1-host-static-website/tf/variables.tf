variable "region" {
  description = "The name of the AWS region to create resources in"
  default     = "us-east-1"
}

variable "web_bucket_name" {
  description = "The name of the web bucket to create"
  default     = "francisco-rod-aws-arch-labone-web"
}

variable "site_name" {
  description = "The DNS domain name of the web site"
  default     = "francisco"
}
