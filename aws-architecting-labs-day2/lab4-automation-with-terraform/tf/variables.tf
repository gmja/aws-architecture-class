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

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 8080
}