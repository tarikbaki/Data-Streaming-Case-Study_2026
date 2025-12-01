# internet gateway (dış dünya bağlantısı)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "trendyol-igw"
  }
}
