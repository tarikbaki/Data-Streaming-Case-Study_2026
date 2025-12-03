# Bu modul, terraform-provider-vagrant ile lokal 4 broker + 3 controller
# + 1 connect + 1 observability VM'ini ayağa kaldırır. Vagrantfile'i terraform
# ile üretip vagrant_vm kaynağı ile çağırıyorum.

locals {
  broker_ips       = [for i in range(var.broker_count) : cidrhost(var.private_network_cidr, 10 + i)]
  controller_ips   = [for i in range(var.controller_count) : cidrhost(var.private_network_cidr, 30 + i)]
  connect_ip       = cidrhost(var.private_network_cidr, 50)
  observability_ip = cidrhost(var.private_network_cidr, 60)
}

resource "local_file" "vagrantfile" {
  filename = "${var.vagrantfile_dir}/Vagrantfile"
  content = templatefile("${path.module}/Vagrantfile.tmpl", {
    box                     = var.box
    broker_ips              = local.broker_ips
    controller_ips          = local.controller_ips
    connect_ip              = local.connect_ip
    observability_ip        = local.observability_ip
    broker_memory_mb        = var.broker_memory_mb
    broker_cpus             = var.broker_cpus
    controller_memory_mb    = var.controller_memory_mb
    controller_cpus         = var.controller_cpus
    connect_memory_mb       = var.connect_memory_mb
    connect_cpus            = var.connect_cpus
    observability_memory_mb = var.observability_memory_mb
    observability_cpus      = var.observability_cpus
  })
}

resource "vagrant_vm" "cluster" {
  vagrantfile_dir = var.vagrantfile_dir
  env = {
    VAGRANT_DEFAULT_PROVIDER = "virtualbox"
  }

  depends_on = [local_file.vagrantfile]
}
