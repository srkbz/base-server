variable "hetzner_dns_token" {}
variable "hetzner_cloud_token" {}

provider "hetznerdns" {
  apitoken = var.hetzner_dns_token
}

provider "hcloud" {
  token = var.hetzner_cloud_token
}

module "base" {
  source = "../../modules/base"

  name           = "empty"
  target_package = "srkbz-base"
  config_extra   = ""
}
