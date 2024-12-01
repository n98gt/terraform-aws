provider "aws" {
  region                   = var.aws_region
  shared_credentials_files = ["./../credentials"]
}

terraform {
  backend "s3" {}
}
