resource "digitalocean_ssh_key" "archives_jenkins_io" {
  name       = "Administrator Public SSH Key for archives.jenkins.io"
  public_key = file("ssh/id_archives_jenkins_io.pub")
}

resource "digitalocean_volume" "archives_jenkins_io_data" {
  region                  = var.region
  name                    = "archivesjenkinsiodata" # Only lowercase alphanum
  size                    = 700
  initial_filesystem_type = "ext4"
  description             = "Data disk for archives.jenkins.io"
}

resource "digitalocean_volume_attachment" "archives_jenkins_io_data" {
  droplet_id = digitalocean_droplet.archives_jenkins_io.id
  volume_id  = digitalocean_volume.archives_jenkins_io_data.id
}

resource "digitalocean_droplet" "archives_jenkins_io" {
  image       = "ubuntu-22-04-x64"
  name        = "archives.jenkins.io"
  region      = var.region
  size        = "s-2vcpu-2gb"
  monitoring  = true
  ipv6        = true
  resize_disk = true
  ssh_keys    = [digitalocean_ssh_key.archives_jenkins_io.fingerprint]
  user_data   = templatefile("${path.root}/.shared-tools/terraform/cloudinit.tftpl", { hostname = "do.archives.jenkins.io" })

}

## Allow accessing the internet in HTTP/HTTPS/DNS and allow incoming HTTP/HTTP from anywhere (public service)
#trivy:ignore:AVD-DIG-0001 trivy:ignore:AVD-DIG-0003
resource "digitalocean_firewall" "archives_jenkins_io" {
  name = "archives.jenkins.io"

  droplet_ids = [digitalocean_droplet.archives_jenkins_io.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["109.88.234.158/32"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
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
}
