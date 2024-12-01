
resource "aws_spot_instance_request" "bastion" {
  ami = data.aws_ami.ubuntu.image_id

  spot_price                     = var.spot_price
  instance_type                  = var.instance_type
  spot_type                      = "one-time" # one-time | persistent
  wait_for_fulfillment           = "true"
  key_name                       = var.ssh_key_name
  instance_interruption_behavior = "terminate" # terminate | stop | hibernate

  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  tags                   = var.instance_tags

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_key_pair" "ssh_public_key" {
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key
}

resource "aws_instance" "k3s" {
  ami = data.aws_ami.ubuntu.image_id

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price                      = 0.016
      spot_instance_type             = "one-time"  # one-time | persistent
      instance_interruption_behavior = "terminate" # terminate | stop | hibernate
    }
  }

  instance_type = var.k3s_instance_type
  key_name      = var.ssh_key_name

  subnet_id              = aws_subnet.private_1.id
  vpc_security_group_ids = [aws_security_group.private.id]
  tags                   = var.instance_tags

  user_data = file("./files/k3s_setup.sh")

  lifecycle {
    ignore_changes = [ami]
  }
}
