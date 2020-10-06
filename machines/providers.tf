terraform {
  required_providers {
    hetznerdns = {
      source = "timohirt/hetznerdns"
      version = "1.1.1"
    }
	hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.22.0"
    }
  }
}
