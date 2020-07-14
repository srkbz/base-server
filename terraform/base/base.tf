variable "hetzner_dns_token" {}
variable "hetzner_cloud_token" {}
variable "service_name" {}

provider "hetznerdns" {
  apitoken = var.hetzner_dns_token
}

provider "hcloud" {
  token = var.hetzner_cloud_token
}

data "hetznerdns_zone" "srkbz" {
    name = "srk.bz"
}

resource "hcloud_server" "server" {
  name = "${var.service_name}.infra.srk.bz"
  image = "ubuntu-20.04"
  location = "nbg1"
  server_type = "cx11"
}

resource "hetznerdns_record" "record" {
    zone_id = data.hetznerdns_zone.srkbz.id
    name = "${var.service_name}.infra"
    value = hcloud_server.server.ipv4_address
    type = "A"
    ttl = 60
}
