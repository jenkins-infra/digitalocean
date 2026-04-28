resource "digitalocean_ssh_key" "archives_jenkins_io" {
  name = "Administrator Public SSH Key for archives.jenkins.io"
  # the private key is stored within sops: config/archives.jenkins.io/id_archives_do_jenkins_io
  public_key = file("ssh/id_archives_jenkins_io.pub")
}

resource "digitalocean_volume" "archives_jenkins_io_data" {
  region                  = var.region
  name                    = "archivesjenkinsiodata" # Only lowercase alphanum
  size                    = 800
  initial_filesystem_type = "ext4"
  description             = "Data disk for archives.jenkins.io"
}

resource "digitalocean_volume_attachment" "archives_jenkins_io_data" {
  droplet_id = digitalocean_droplet.archives_jenkins_io.id
  volume_id  = digitalocean_volume.archives_jenkins_io_data.id
}

resource "digitalocean_droplet" "archives_jenkins_io" {
  image       = "ubuntu-22-04-x64"
  name        = local.archives_jenkins_io_vmname
  region      = var.region
  size        = "s-4vcpu-8gb"
  monitoring  = true
  ipv6        = true
  resize_disk = true
  # default username is root - https://docs.digitalocean.com/products/droplets/how-to/connect-with-ssh/
  ssh_keys  = [digitalocean_ssh_key.archives_jenkins_io.fingerprint]
  user_data = templatefile("${path.root}/cloudinit.tftpl", { hostname = local.archives_jenkins_io_fqdn })
  tags      = concat([for key, value in local.default_tags : "${key}:${value}"])

  lifecycle {
    ignore_changes = [
      # https://github.com/digitalocean/terraform-provider-digitalocean/pull/1515 (introduced with https://github.com/digitalocean/terraform-provider-digitalocean/releases/tag/v2.82.0)
      # introduced a regression around public_networking. Let's ignore changes to this attribute to avoid droplet destruction until https://github.com/digitalocean/terraform-provider-digitalocean/issues/1524 is fixed.
      public_networking,
      # Also ignoring user_data in case we make unwanted changes to the tpl file (which could lead to destroying a droplet inadvertently).
      user_data,
    ]
  }
}
