resource "aws_vpc" "main" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "dedicated"

  tags = {
    Name = "${var.vpc_name}"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.vpc_public_subnet_cidr}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_public_subnet_name}"
  }
}

resource "aws_subnet" "private1" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.vpc_private_subnet1_cidr}"

  tags = {
    Name = "${var.vpc_private_subnet1_name}"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.vpc_private_subnet2_cidr}"

  tags = {
    Name = "${var.vpc_private_subnet2_name}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "${var.vpc_igw_name}"
  }
}
