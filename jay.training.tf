resource "digitalocean_ssh_key" "jay_training" {
  name       = "Public SSH Key for jay.training"
  public_key = file("ssh/id_jay_training.pub")
}

resource "digitalocean_volume" "jay_training_data" {
  region                  = var.region
  name                    = "jaytrainingdata" # Only lowercase alphanum
  size                    = 750
  initial_filesystem_type = "ext4"
  description             = "Data disk for jay.training"
}

resource "digitalocean_volume_attachment" "jay_training_data" {
  droplet_id = digitalocean_droplet.jay_training.id
  volume_id  = digitalocean_volume.jay_training_data.id
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
  user_data   = templatefile("${path.root}/cloudinit.tftpl", { hostname = "jay.training.io" })
  tags        = concat([for key, value in local.default_tags : "${key}:${value}"])
}
