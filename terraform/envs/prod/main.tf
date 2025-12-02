# Temel altyapıyı modüler şekilde ayağa kaldırıyorum.
# VPC + subnet + SG ardından compute kaynaklarını tek dosyada bağlıyorum.

provider "aws" {
  # Ödev sırasında gerçek kimlik bilgisi vermemek için dummy credential verdim.
  # Gerçekte bu bloktaki access/secret/profile ayarlarını kaldırıp gerçek kimlik bilgisi kullanılacak
  region                      = "eu-central-1"
  access_key                  = "dummy"
  secret_key                  = "dummy"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# S3 backend kimlik bilgisi gerektirdiği için ödev süresince local state kullanıyorum.
# Gerçek ortamda aşağıdaki local backend'i s3 ile değiştir.
terraform {
  # backend "s3" {
  #   bucket = "trendyol-data-streaming-tfstate"
  #   key    = "envs/prod/terraform.tfstate"
  #   region = "eu-central-1"
  # }
  backend "local" {}
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
  key_name     = "challenge-key"
  user_data    = file("${path.module}/user_data.sh")
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
