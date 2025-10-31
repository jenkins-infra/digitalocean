resource "digitalocean_ssh_key" "usage_jenkins_io" {
  name = "Administrator Public SSH Key for usage.jenkins.io"
  # the private key is stored within sops: config/usage.jenkins.io/id_do_usage_jenkins_io
  public_key = file("ssh/id_do_usage_jenkins_io.pub")
}

resource "digitalocean_volume" "usage_jenkins_io_data" {
  region                  = var.region
  name                    = "usagejenkinsiodata" # Only lowercase alphanum
  size                    = 1500
  initial_filesystem_type = "ext4"
  description             = "Data disk for usage.jenkins.io"
}

resource "digitalocean_volume_attachment" "usage_jenkins_io_data" {
  droplet_id = digitalocean_droplet.usage_jenkins_io.id
  volume_id  = digitalocean_volume.usage_jenkins_io_data.id
}

resource "digitalocean_droplet" "usage_jenkins_io" {
  image       = "ubuntu-22-04-x64"
  name        = local.usage_jenkins_io_vmname
  region      = var.region
  size        = "s-2vcpu-4gb"
  monitoring  = true
  ipv6        = true
  resize_disk = true
  # default username is root - https://docs.digitalocean.com/products/droplets/how-to/connect-with-ssh/
  ssh_keys  = [digitalocean_ssh_key.usage_jenkins_io.fingerprint]
  user_data = templatefile("${path.root}/cloudinit/usage-cloudinit.tftpl", { hostname = local.usage_jenkins_io_fqdn })
  tags      = concat([for key, value in local.default_tags : "${key}:${value}"], ["usage_jenkins_io"])
}
