resource "aws_vpc" "test" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags                 = var.vpc_tags
}

resource "aws_eip" "nat" {
  domain = "vpc"
}
