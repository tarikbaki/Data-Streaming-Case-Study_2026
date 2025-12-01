# Security Group'u burada tutuyorum.
# Challenge için şimdilik tamamen açık bıraktım, normalde port bazında kısıtlardım.

resource "aws_security_group" "this" {
  name        = "trendyol-sg"
  description = "allow required ports"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
