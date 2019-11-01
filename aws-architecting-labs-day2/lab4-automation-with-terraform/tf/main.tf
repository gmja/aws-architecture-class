terraform {
  required_version = "~> 0.12.01"

  backend "s3" {
    encrypt = true
    bucket  = "rfrancisco-aws-arch-tfstate"
    region  = "us-east-1"
    key     = "awsarchitecture/labfour"
  }
}

provider "aws" {
  version    = "~> 2.9"
  region     = "${var.region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

data "aws_availability_zones" "all" {}

resource "aws_security_group" "rod-francisco-lab9" {
  name = "rod-francisco-ws-sg"
  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "rod-francisco-lab9" {
  launch_configuration = "${aws_launch_configuration.rod-francisco-lab9.id}"
  availability_zones   = "${data.aws_availability_zones.all.names}"
  min_size             = 2
  max_size             = 10
  tag {
    key                 = "Name"
    value               = "rod-francisco-lab9-asg"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "rod-francisco-lab9" {
  image_id        = "ami-2d39803a"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.rod-francisco-lab9.id}"]
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "rod-francisco-lab9" {
  ami = "ami-2d39803a"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.rod-francisco-lab9.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  tags = {
    Name = "rod-francisco-l9-ws"
  }
}

resource "aws_security_group" "rod-francisco-lab9-elb" {
  name = "rod-francisco-elb-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "rod-francisco-lab9" {
  name               = "rod-francisco-lab9-elb"
  availability_zones = "${data.aws_availability_zones.all.names}"
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
  }

  security_groups = ["${aws_security_group.rod-francisco-lab9-elb.id}"]

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:${var.server_port}/"
  }  
}
