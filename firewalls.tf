resource "digitalocean_firewall" "default" {
  name        = "default"
  droplet_ids = [digitalocean_droplet.archives_jenkins_io.id]

  inbound_rule {
    protocol   = "tcp"
    port_range = "22"

    source_addresses = flatten(concat(
      module.jenkins_infra_shared_data.outbound_ips["private.vpn.jenkins.io"], # connections routed through the VPN
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
      module.jenkins_infra_shared_data.outbound_ips["pkg.jenkins.io"],                    # Data sync script from the `pkg` VM
      module.jenkins_infra_shared_data.outbound_ips["trusted.ci.jenkins.io"],             # permanent agent of update_center2
      module.jenkins_infra_shared_data.outbound_ips["trusted.sponsorship.ci.jenkins.io"], # ephemeral agents for crawler
      # TODO: track with updatecli - https://reports.jenkins.io/jenkins-infra-data-reports/azure-net.json
      ["172.176.126.194"], # VPN outbound IP
      # TODO: track with updatecli - https://reports.jenkins.io/jenkins-infra-data-reports/azure-net.json
      ["172.200.139.164", "128.24.89.148"], # Outbound IPv4 of the privatek8s-sponsorship.jenkins.io NAT gateway (release.ci agents, controller and infra.ci controller)
      # TODO: track with updatecli - https://reports.jenkins.io/jenkins-infra-data-reports/azure-net.json
      ["20.122.14.108", "20.186.70.154"], # Outbound IPv4 of the infracijioagents-1-sponsorship NAT gateway (infra.ci agents)
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
      module.jenkins_infra_shared_data.external_service_ips["ftp-osl.osuosl.org"],
      module.jenkins_infra_shared_data.outbound_ips["pkg.jenkins.io"],
    ))
  }
  outbound_rule {
    protocol   = "tcp"
    port_range = "22"
    destination_addresses = flatten(concat(
      module.jenkins_infra_shared_data.external_service_ips["ftp-osl.osuosl.org"],
      module.jenkins_infra_shared_data.outbound_ips["pkg.jenkins.io"],
    ))
  }
}

resource "digitalocean_firewall" "web" {
  name        = "web"
  droplet_ids = [digitalocean_droplet.archives_jenkins_io.id]

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
