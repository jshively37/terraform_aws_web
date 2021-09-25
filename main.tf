provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block = var.private_cidr_block
  tags = {
    Name = "VPC-PRIVATE-${var.business_unit}"
  }
}

resource "aws_subnet" "private_subnet" {
  cidr_block        = var.private_cidr_block
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_vpc" "public_vpc" {
  cidr_block = var.public_cidr_block
  enable_dns_hostnames = "true"
  tags = {
    Name = "VPC-PUBLIC-${var.business_unit}"
  }
}

resource "aws_subnet" "public_subnet" {
  cidr_block        = var.public_cidr_block
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

}

resource "aws_route_table" "igw_route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "private_nat" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.igw_route.id
}

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
  count         = var.instance_count
  ami           = data.aws_ami.linux.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private_subnet.id

  tags = {
    Name = "EC2-${var.business_unit}-${count.index + 1}"
  }
}


resource "aws_security_group" "sg_web_server" {
  name   = "sg_elb"
  vpc_id = aws_vpc.public_vpc.id

  #Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_elb" "lb_web_server" {
  name = "lb-web"

  subnets         = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
  security_groups = [aws_security_group.sg_web_server.id]
  instances       = "${aws_instance.linux.*.id}"

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags = {
    Name = "LB-HTTP-${var.business_unit}"
  }
}


