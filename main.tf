provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block = var.network_cidr_block
  enable_dns_hostnames = "true"
  tags = {
    Name = "VPC-${var.business_unit}"
  }
}


resource "aws_subnet" "public_subnet" {
  cidr_block        = var.public_cidr_block
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    "Name" = "SUBNET-${var.business_unit}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "IGW-${var.business_unit}"
  }
}

resource "aws_route_table" "route_igw" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    "Name" = "ROUTE-${var.business_unit}"
  }
}

resource "aws_route_table_association" "rta_igw" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_igw.id
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
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "EC2-${var.business_unit}-${count.index + 1}"
  }
}


resource "aws_security_group" "sg_web_server" {
  name   = "sg_elb"
  vpc_id = aws_vpc.vpc.id

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

  subnets         = [aws_subnet.public_subnet.id]
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

resource "aws_security_group" "sg-http" {
  name   = "sg_http"
  vpc_id = aws_vpc.vpc.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.network_cidr_block]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
