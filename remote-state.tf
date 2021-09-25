terraform {
  backend "remote" {
    organization = "jshively"
    workspaces {
      name = "terraform_aws_web"
    }
  }
}
