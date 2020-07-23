terraform {
  backend "pg" {}
}

variable "hetzner_dns_token" {}
variable "hetzner_cloud_token" {}

provider "hetznerdns" {
	apitoken = var.hetzner_dns_token
}

provider "hcloud" {
	token = var.hetzner_cloud_token
}

module "base" {
	source = "./modules/base"

	target_package = "srkbz-minecraft"
	config_extra = "MINECRAFT_DOMAIN=${terraform.workspace}.infra.srk.bz\n"
}

output "monitoring_secret" {
  value = module.base.monitoring_secret
}
output "monitoring_domain" {
  value = module.base.monitoring_domain
}
