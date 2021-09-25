variable "region" {
  description = "AWS region"
}

variable "instance_type" {
  description = "Type of EC2 instance to provision"
}

variable "business_unit" {
  description = "Business unit for the EC2 instance"
}

variable "instance_count" {
  description = "Number of EC2 instances to build"
}

variable "network_cidr_block" {
  description = "/22 assigned to location"
}

variable "public_cidr_block" {
  description = "Public CIDR Block"
}

variable "private_cidr_block" {
  description = "Private CIDR Block"
}
