provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

data "aws_ami" "linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20210813.1-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "linux" {
  count         = var.instance_count_public
  ami           = data.aws_ami.linux.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnet.id

  tags = {
    Name = "EC2-${var.business_unit}-${count.index + 1}"
  }
}

resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "VPC-${var.business_unit}"
  }
}

resource "aws_subnet" "subnet" {
  cidr_block        = var.cidr_block
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
}
