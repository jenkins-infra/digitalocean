resource "digitalocean_ssh_key" "census_jenkins_io" {
  name = "Administrator Public SSH Key for census.jenkins.io"
  # the private key is stored within sops: config/census.jenkins.io/id_do_census_jenkins_io
  public_key = file("ssh/id_do_census_jenkins_io.pub")
}

resource "digitalocean_volume" "census_jenkins_io_data" {
  region                  = var.region
  name                    = "censusjenkinsiodata" # Only lowercase alphanum
  size                    = 100
  initial_filesystem_type = "ext4"
  description             = "Data disk for census.jenkins.io"
}

resource "digitalocean_volume_attachment" "census_jenkins_io_data" {
  droplet_id = digitalocean_droplet.census_jenkins_io.id
  volume_id  = digitalocean_volume.census_jenkins_io_data.id
}

resource "digitalocean_droplet" "census_jenkins_io" {
  image       = "ubuntu-22-04-x64"
  name        = local.census_jenkins_io_vmname
  region      = var.region
  size        = "s-2vcpu-4gb"
  monitoring  = true
  ipv6        = true
  resize_disk = true
  # default username is root - https://docs.digitalocean.com/products/droplets/how-to/connect-with-ssh/
  ssh_keys  = [digitalocean_ssh_key.census_jenkins_io.fingerprint]
  user_data = templatefile("${path.root}/cloudinit/census-cloudinit.tftpl", { hostname = local.census_jenkins_io_fqdn })
  tags      = concat([for key, value in local.default_tags : "${key}:${value}"], ["census_jenkins_io"])
}
