resource "digitalocean_firewall" "default" {
  name = "default"
  droplet_ids = [
    digitalocean_droplet.archives_jenkins_io.id,
    digitalocean_droplet.usage_jenkins_io.id,
    digitalocean_droplet.census_jenkins_io.id,
  ]

  inbound_rule {
    protocol   = "tcp"
    port_range = "22"

    source_addresses = flatten(concat(
      split(" ", local.outbound_ips_private_vpn_jenkins_io), # connections routed through the VPN
    ))
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  ## Allow puppet protocol to puppet.jenkins.io
  outbound_rule {
    protocol              = "tcp"
    port_range            = "8140"
    destination_addresses = ["20.12.27.65/32"] # todo updatecli this ip
  }
}

resource "digitalocean_firewall" "archives" {
  name        = "archives"
  droplet_ids = [digitalocean_droplet.archives_jenkins_io.id]

  inbound_rule {
    protocol   = "tcp"
    port_range = "22"

    source_addresses = flatten(concat(
      split(" ", local.outbound_ips_pkg_origin_jenkins_io),  # Data sync script from the `pkg` VM
      split(" ", local.outbound_ips_trusted_ci_jenkins_io),  # trusted.ci.jenkins.io (controller and all agents) for rsync data transfer
      split(" ", local.outbound_ips_private_vpn_jenkins_io), # connections routed through the VPN
      split(" ", local.outbound_ips_infra_ci_jenkins_io),    # infra.ci.jenkins.io (controller and all agents) for SSH management
    ))
  }

  # Allow rsync. IP restriction is set at rsync service level, not at firewall level
  inbound_rule {
    protocol   = "tcp"
    port_range = "873"

    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  ## Allow rsyncing to OSUOSL and pkg.jenkins.io
  outbound_rule {
    protocol   = "tcp"
    port_range = "873"
    destination_addresses = flatten(concat(
      split(" ", local.inbound_ips_ftp_osl_osuosl_org),
      split(" ", local.inbound_ips_pkg_origin_jenkins_io),
    ))
  }
  outbound_rule {
    protocol   = "tcp"
    port_range = "22"
    destination_addresses = flatten(concat(
      split(" ", local.inbound_ips_ftp_osl_osuosl_org),
      split(" ", local.inbound_ips_pkg_origin_jenkins_io),
    ))
  }
}

resource "digitalocean_firewall" "web" {
  name        = "web"
  droplet_ids = [digitalocean_droplet.archives_jenkins_io.id, digitalocean_droplet.usage_jenkins_io.id]

  # open http to serve pages
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # open https to serve pages
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
}


resource "digitalocean_firewall" "census" {
  name        = "census"
  droplet_ids = [digitalocean_droplet.census_jenkins_io.id]

  # Allow access from/to the old census VM
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [local.outbound_ips_census_aws_jenkins_io]
  }
  outbound_rule {
    protocol              = "tcp"
    port_range            = "22"
    destination_addresses = [local.outbound_ips_census_aws_jenkins_io]
  }

  # Allow SSH access from trusted.ci.jenkins.io
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [local.outbound_ips_trusted_ci_jenkins_io]
  }
}
