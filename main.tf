provider "aws" {
  region = var.region
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
  count         = var.instance_count_public
  ami           = data.aws_ami.linux.id
  instance_type = var.instance_type

  tags = {
    Name = "Terraform-${count.index + 1}"
  }
}
