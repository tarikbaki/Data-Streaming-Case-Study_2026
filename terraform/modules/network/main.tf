resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.20.1.0/24"
  availability_zone = "eu-central-1a"
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.20.2.0/24"
  availability_zone = "eu-central-1b"
}

resource "aws_subnet" "public_c" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.20.3.0/24"
  availability_zone = "eu-central-1c"
}
