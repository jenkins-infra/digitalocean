resource "digitalocean_ssh_key" "jay_training" {
  name       = "Public SSH Key for jay.training"
  public_key = file("ssh/id_jay_training.pub")
}

resource "digitalocean_droplet" "jay_training" {
  image       = "ubuntu-22-04-x64"
  name        = "jay.training"
  region      = var.region
  size        = "s-4vcpu-8gb"
  monitoring  = true
  ipv6        = true
  resize_disk = true
  ssh_keys    = [digitalocean_ssh_key.jay_training.fingerprint]
  tags        = concat([for key, value in local.default_tags : "${key}:${value}"])
}
