# üç tane public subnet açıyorum
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.20.1.0/24"
  availability_zone = var.azs[0]

  tags = {
    Name = "public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.20.2.0/24"
  availability_zone = var.azs[1]

  tags = {
    Name = "public-b"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.20.3.0/24"
  availability_zone = var.azs[2]

  tags = {
    Name = "public-c"
  }
}
