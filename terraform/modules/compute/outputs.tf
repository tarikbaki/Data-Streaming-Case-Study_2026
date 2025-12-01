# Burada EC2 instance IP'lerini dışarıya çıkartıyorum.
# Ansible inventory ve Prometheus target scriptleri bu output'ları kullanıyor.
# Broker, controller, connect ve observability IP'leri parent seviyeye dönüyor.


output "broker_ips" {
  value = aws_instance.broker[*].public_ip
}

output "controller_ips" {
  value = aws_instance.controller[*].public_ip
}

output "connect_ip" {
  value = aws_instance.connect.public_ip
}

output "obs_ip" {
  value = aws_instance.observability.public_ip
}
