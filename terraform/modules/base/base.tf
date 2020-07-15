data "hetznerdns_zone" "srkbz" {
	name = "srk.bz"
}

data "hcloud_ssh_keys" "all_keys" {}

resource "random_string" "monitoring-secret" {
  length = 32
  special = false
  number = true
  lower = true
  upper = false
}

resource "hcloud_server" "server" {
	name = "${terraform.workspace}.infra.srk.bz"
	image = "ubuntu-20.04"
	location = "nbg1"
	server_type = "cx11"
	user_data = file("${path.module}/cloudinit")

	ssh_keys = data.hcloud_ssh_keys.all_keys.ssh_keys.*.id

	connection {
		type = "ssh"
		user = "root"
		private_key = file("~/.ssh/id_rsa")
		host = hcloud_server.server.ipv4_address
	}

	provisioner "remote-exec" {
		inline = [
			"mkdir -p /etc/srkbz",
			"touch /etc/srkbz/config.env"
		]
	}

	provisioner "file" {
		content = "MONITORING_DOMAIN=m-${terraform.workspace}.infra.srk.bz\nMONITORING_SECRET_PATH=${random_string.monitoring-secret.result}\n"
		destination = "/etc/srkbz/config.env"
	}
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
