# Compute modülüne dışarıdan gönderilen değişkenleri burada tanımlıyorum.
# Buradan EC2'lerin VPC, subnet ve security group bilgileri geliyor.

variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "sg_id" {
  type = string
}
