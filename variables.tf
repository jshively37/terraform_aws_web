variable "region" {
  description = "AWS region"
}

variable "instance_type" {
  description = "Type of EC2 instance to provision"
}

variable "business_unit" {
  description = "Business unit for the EC2 instance"
}

variable "instance_count_public" {
  description = "Number of EC2 instances to build"
}

variable "cidr_block" {
  description = "CIDR Block"
}
