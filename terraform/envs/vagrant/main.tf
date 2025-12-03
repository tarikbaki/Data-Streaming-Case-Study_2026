# Lokal ortam icin Vagrant provider'i ile VM'leri ayağa kaldiriyorum.

terraform {
  required_providers {
    vagrant = {
      source  = "bmatcuk/vagrant"
      version = "~> 3.0"
    }
  }
  backend "local" {}
}

provider "vagrant" {}

locals {
  project_name = "trendyol-data-streaming"
}

module "cluster" {
  source                = "../../modules/vagrant_cluster"
  project_name          = local.project_name
  vagrantfile_dir       = path.module
  private_network_cidr  = "192.168.56.0/24"
  box                   = "bento/ubuntu-22.04"
  broker_count          = 4
  controller_count      = 3
  broker_memory_mb      = 4096
  broker_cpus           = 2
  controller_memory_mb  = 2048
  controller_cpus       = 2
  connect_memory_mb     = 4096
  connect_cpus          = 2
  observability_memory_mb = 3072
  observability_cpus      = 2
}

output "broker_ips" {
  value = module.cluster.broker_ips
}

output "controller_ips" {
  value = module.cluster.controller_ips
}

output "connect_ip" {
  value = module.cluster.connect_ip
}

output "obs_ip" {
  value = module.cluster.observability_ip
}
