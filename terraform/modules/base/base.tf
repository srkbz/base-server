data "hetznerdns_zone" "srkbz" {
	name = "srk.bz"
}

resource "hcloud_server" "server" {
	name = "${terraform.workspace}.infra.srk.bz"
	image = "ubuntu-20.04"
	location = "nbg1"
	server_type = "cx11"
	user_data = file("${path.module}/cloudinit")
}

resource "hetznerdns_record" "record" {
	zone_id = data.hetznerdns_zone.srkbz.id
	name = "${terraform.workspace}.infra"
	value = hcloud_server.server.ipv4_address
	type = "A"
	ttl = 60
}

resource "hetznerdns_record" "mon-record" {
	zone_id = data.hetznerdns_zone.srkbz.id
	name = "m-${terraform.workspace}.infra"
	value = "${terraform.workspace}.infra"
	type = "CNAME"
	ttl = 60
}
