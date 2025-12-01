# VPC tanımı burada, subnetler subnets.tf altında tutuluyor.

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
}
