# Bu network modülünde VPC ve subnet ayarlarını burada topluyorum.
# Modüller karışmasın diye hepsini ayrı dosyalara böldüm.

# network modülü için basit değişkenler
variable "cidr_block" {
  type = string
}

variable "azs" {
  type = list(string)
}
