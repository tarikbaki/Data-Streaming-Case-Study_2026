output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnets" {
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
    aws_subnet.public_c.id
  ]
}
