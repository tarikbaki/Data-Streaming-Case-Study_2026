# Vagrant tabanli lokal topoloji icin parametreler.
# Varsayilanlar VirtualBox + Ubuntu 22.04 icin ayarlandi.

variable "project_name" {
  description = "VM isim prefix'i"
  type        = string
}

variable "vagrantfile_dir" {
  description = "Vagrantfile'in yazilacagi dizin"
  type        = string
}

variable "box" {
  description = "Kullanilacak Vagrant box"
  type        = string
  default     = "bento/ubuntu-22.04"
}

variable "private_network_cidr" {
  description = "Host-only network CIDR'i (statik IP'leri buradan uretirim)"
  type        = string
  default     = "192.168.56.0/24"
}

variable "broker_count" {
  description = "Broker sayisi"
  type        = number
  default     = 4
}

variable "controller_count" {
  description = "Controller sayisi"
  type        = number
  default     = 3
}

variable "broker_memory_mb" {
  description = "Broker VM bellek (MB)"
  type        = number
  default     = 4096
}

variable "broker_cpus" {
  description = "Broker VM CPU sayisi"
  type        = number
  default     = 2
}

variable "controller_memory_mb" {
  description = "Controller VM bellek (MB)"
  type        = number
  default     = 2048
}

variable "controller_cpus" {
  description = "Controller VM CPU sayisi"
  type        = number
  default     = 2
}

variable "connect_memory_mb" {
  description = "Connect VM bellek (MB)"
  type        = number
  default     = 4096
}

variable "connect_cpus" {
  description = "Connect VM CPU sayisi"
  type        = number
  default     = 2
}

variable "observability_memory_mb" {
  description = "Observability VM bellek (MB)"
  type        = number
  default     = 3072
}

variable "observability_cpus" {
  description = "Observability VM CPU sayisi"
  type        = number
  default     = 2
}
