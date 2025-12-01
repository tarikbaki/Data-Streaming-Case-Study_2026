# Temel altyapıyı modüler şekilde ayağa kaldırıyorum.
# VPC + subnet + SG ardından compute kaynaklarını tek dosyada bağlıyorum.

provider "aws" {
  region = "eu-central-1"
}

locals {
  project_name = "trendyol-data-streaming"
}

module "network" {
  source     = "../../modules/network"
  cidr_block = "10.20.0.0/16"
  azs        = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

module "security" {
  source = "../../modules/security"
  vpc_id = module.network.vpc_id
}

module "compute" {
  source       = "../../modules/compute"
  project_name = local.project_name
  vpc_id       = module.network.vpc_id
  subnets      = module.network.subnets
  sg_id        = module.security.sg_id
}

output "broker_ips" {
  value = module.compute.broker_ips
}

output "controller_ips" {
  value = module.compute.controller_ips
}

output "connect_ip" {
  value = module.compute.connect_ip
}

output "obs_ip" {
  value = module.compute.obs_ip
}
