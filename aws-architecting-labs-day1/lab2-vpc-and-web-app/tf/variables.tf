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

variable "vpc_name" {
  description = "The name of the VPC to create"
  default     = "rod-francisco-vpc"
}

variable "vpc_cidr" {
  description = "The VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "The AZ to put VPC subnets in"
  default     = ["us-east-1a"]
}

variable "vpc_public_subnet_name" {
  description = "The name of VPC public subnet"
  default     = "rod-francisco-public"
}

variable "vpc_public_subnet_cidr" {
  description = "The CIDR of the public subnet"
  default     = "10.0.0.0/24"
}

variable "vpc_private_subnet1_name" {
  description = "The name of first private subnet"
  default     = "rod-francisco-private1"
}

variable "vpc_private_subnet1_cidr" {
  description = "The CIDR of the first private subnet"
  default     = "10.0.2.0/23"
}

variable "vpc_private_subnet2_name" {
  description = "The name of second private subnet"
  default     = "rod-francisco-private2"
}

variable "vpc_private_subnet2_cidr" {
  description = "The CIDR of the second private subnet"
  default     = "10.0.4.0/23"
}

variable "vpc_igw_name" {
  description = "Internet gateway name"
  default     = "rod-francisco-igw"
}
