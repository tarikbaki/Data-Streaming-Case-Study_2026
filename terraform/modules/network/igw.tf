# Internet Gateway'i burada tutuyorum.
# VPC dış dünyaya çıksın diye IGW şart.

# internet gateway (dış dünya bağlantısı)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "trendyol-igw"
  }
}
