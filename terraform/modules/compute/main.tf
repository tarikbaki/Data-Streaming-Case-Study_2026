# Bu compute modülünde broker, controller, connect ve observability için EC2'leri oluşturuyorum.
# Terraform apply sonrası bütün instance'lar burada yaratılıyor.
# Subnet ve SG bilgilerini dışarıdan alıyorum, modül sade kalsın diye.


variable "project_name" { type = string }
variable "vpc_id"        { type = string }
variable "subnets"       { type = list(string) }
variable "sg_id"         { type = string }

resource "aws_instance" "broker" {
  count         = 4
  ami           = "ami-0f5a09cc5b6828036"
  instance_type = "t3.medium"
  subnet_id     = var.subnets[count.index % 2]  # A/B dağılımı
  vpc_security_group_ids = [var.sg_id]

  tags = {
    Name = "${var.project_name}-broker-${count.index}"
  }
}

resource "aws_instance" "controller" {
  count         = 3
  ami           = "ami-0f5a09cc5b6828036"
  instance_type = "t3.small"
  subnet_id     = var.subnets[count.index]   # 0=a, 1=b, 2=c
  vpc_security_group_ids = [var.sg_id]

  tags = {
    Name = "${var.project_name}-controller-${count.index}"
  }
}

resource "aws_instance" "connect" {
  ami           = "ami-0f5a09cc5b6828036"
  instance_type = "t3.small"
  subnet_id     = var.subnets[0]
  vpc_security_group_ids = [var.sg_id]

  tags = {
    Name = "${var.project_name}-connect"
  }
}

resource "aws_instance" "observability" {
  ami           = "ami-0f5a09cc5b6828036"
  instance_type = "t3.small"
  subnet_id     = var.subnets[1]
  vpc_security_group_ids = [var.sg_id]

  tags = {
    Name = "${var.project_name}-observability"
  }
}
