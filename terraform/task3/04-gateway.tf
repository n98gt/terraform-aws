resource "aws_internet_gateway" "test" {
  vpc_id = aws_vpc.test.id

  tags = var.gateway_tags
}


resource "aws_nat_gateway" "test" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_2.id

  tags = {
    Name = "test"
  }

  depends_on = [aws_internet_gateway.test]
}
