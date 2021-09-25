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
  count         = var.instance_count
  ami           = data.aws_ami.linux.id
  instance_type = var.instance_type
  # subnet_id     = aws_subnet.subnet.id

  user_data     = <<-EOF
                  #!/bin/bash
                  sudo su
                  yum -y install httpd
                  echo "<p> My Fancy Blog </p>" >> /var/www/html/index.html
                  sudo systemctl enable httpd
                  sudo systemctl start httpd
                  EOF

  tags = {
    Name = "EC2-${var.business_unit}-${count.index + 1}"
  }
}

resource "aws_vpc" "private_vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "VPC-PRIVATE-${var.business_unit}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.private_vpc.id

  tags = {
    Name = "VPC-${var.business_unit}"
  }
}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.private_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_subnet" "private_subnet" {
  cidr_block        = var.cidr_block
  vpc_id            = aws_vpc.private_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_route_table_association" "rta-subnet" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.rtb.id
}

resource "aws_security_group" "security_group" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.private_vpc.id
  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "HTTP-${var.business_unit}"
  }
}
