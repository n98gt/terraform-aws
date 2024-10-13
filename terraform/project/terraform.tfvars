# if region is changed, terraform «forgets»(i.e. does not destroy) resources created in previous region
aws_region = "eu-north-1" # eu-north-1 Stockholm

#  ---------------------------------------------------------------------------------
#  vpc & networking
#  ---------------------------------------------------------------------------------

vpc_cidr_block = "10.0.0.0/16"

vpc_tags = {
  Name = "test"
}

gateway_tags = {
  Name = "test"
}

#  ---------------------------------------------------------------------------------
#  vm instance
#  ---------------------------------------------------------------------------------

instance_type = "t3.nano"
instance_tags = {
  Name = "test"
}

ssh_key_name   = "ec2_key_pair"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCDhBd9jc2/kpT0CBDIjjx26vtyO0veOO+Y6m/dJZbN2zdnucvBSezHkwj0+cev+tCKzGkHNpaNWefSnPGy7DwJB5MuARFqTXeD9/wKi3g9s8OuXS4AcfYqsECrG4eFcBZByKEX2Asjel9cJjeniiucyvKR83mYMvUQp7pN/+17WkgjwSYmFrBQBAJJ+NxlBwYNb/w39hL+PB/QwzeIsYbHkgcpc9k1/h9FgcRNpSpZdRR2LMHPPTHMNvsf4pmw3II8KT1Q7wOJIQN3KziV5IVeXOqAyA905FHaJexrxvMHJfm4AcguuOTn5RKK8hN+UD9BpkZ2j2Od+LRBV3bTY/Cx"
