output "broker_ips" {
  description = "Broker VM IP listesi"
  value       = local.broker_ips
}

output "controller_ips" {
  description = "Controller VM IP listesi"
  value       = local.controller_ips
}

output "connect_ip" {
  description = "Kafka Connect VM IP"
  value       = local.connect_ip
}

output "observability_ip" {
  description = "Observability VM IP"
  value       = local.observability_ip
}

output "private_network_cidr" {
  description = "Host-only network CIDR"
  value       = var.private_network_cidr
}
