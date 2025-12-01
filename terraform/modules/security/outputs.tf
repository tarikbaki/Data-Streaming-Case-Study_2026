# SG ID'yi dışarıya çıkartıyorum, compute modülünün instance'lara takması için.
output "sg_id" {
  value = aws_security_group.this.id
}
