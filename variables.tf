variable "region" {
  description = "AWS region"
}

variable "instance_type" {
  description = "Type of EC2 instance to provision"
}

variable "instance_name" {
  description = "EC2 instance name"
}

variable "instance_count_public" {
  description = "Number of EC2 instances to build"
}
