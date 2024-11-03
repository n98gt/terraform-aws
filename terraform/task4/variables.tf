variable "aws_region" {
  type    = string
  default = "us-east-1"
}

#  ---------------------------------------------------------------------------------
#  vpc & networking
#  ---------------------------------------------------------------------------------

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/24"
}

variable "vpc_tags" {
  type = object({
    Name = string
  })
  default = {
    Name = "virtual network for test"
  }
}

variable "public_subnet_1_cidr" {
  description = "cidr block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "cidr block for public subnet 1"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "cidr block for public subnet 1"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_2_cidr" {
  description = "cidr block for public subnet 1"
  type        = string
  default     = "10.0.4.0/24"
}

variable "gateway_tags" {
  type = object({
    Name = string
  })
  default = {
    Name = "gateway for test"
  }
}

#  ---------------------------------------------------------------------------------
#  vm instance
#  ---------------------------------------------------------------------------------

variable "spot_price" {
  type    = string
  default = "0.016"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ssh_key_name" {
  type    = string
  default = "ec2-ssh-key"
}

variable "ssh_public_key" {
  type = string
}

variable "instance_tags" {
  type = object({
    Name = string
  })
  default = {
    Name = "test"
  }
}

variable "k3s_instance_type" {
  type    = string
  default = "t3.small"
}
