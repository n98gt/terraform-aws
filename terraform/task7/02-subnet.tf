resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.test.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.test.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_2"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.test.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = "${var.aws_region}a"
  tags = {
    Name = "private_1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.test.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = "${var.aws_region}b"
  tags = {
    Name = "private_2"
  }
}
