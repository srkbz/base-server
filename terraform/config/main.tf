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

resource "random_string" "minecraft-admin-password" {
  length = 16
  special = false
  number = true
  lower = true
  upper = false
}

module "base" {
	source = "./modules/base"

	target_package = "srkbz-minecraft"
	config_extra = <<EOF
MINECRAFT_DOMAIN=${terraform.workspace}.infra.srk.bz
MINECRAFT_ADMIN_PASSWORD=${base64encode(bcrypt(random_string.minecraft-admin-password.result))}
EOF
}

output "minecraft_admin_domain" {
	value = "${terraform.workspace}.infra.srk.bz"
}
output "minecraft_admin_password" {
	value = random_string.minecraft-admin-password.result
}
output "monitoring_secret" {
	value = module.base.monitoring_secret
}
output "monitoring_domain" {
	value = module.base.monitoring_domain
}
