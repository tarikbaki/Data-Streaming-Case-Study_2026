# network modülü için basit değişkenler
variable "cidr_block" {
  type = string
}

variable "azs" {
  type = list(string)
}
