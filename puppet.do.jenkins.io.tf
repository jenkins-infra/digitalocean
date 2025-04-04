resource "digitalocean_ssh_key" "puppet_do_jenkins_io" {
  name       = "Administrator Public SSH Key for puppet_do.jenkins.io"
  public_key = file("ssh/id_puppet_do_jenkins_io.pub")
}

resource "digitalocean_droplet" "puppet_do_jenkins_io" {
  image       = "ubuntu-20-04-x64"
  name        = "puppet.do.jenkins.io"
  region      = var.region
  size        = "s-2vcpu-8gb-amd" # Basic AMD 	s-2vcpu-8gb-amd	8 GB 	2 	100 GB 	5 TB 	$42 	$0.0625 https://slugs.do-api.dev/
  monitoring  = true
  ipv6        = true
  resize_disk = true
  ssh_keys    = [digitalocean_ssh_key.puppet_do_jenkins_io.fingerprint]
  user_data   = templatefile("${path.root}/cloudinit.tftpl", { hostname = "puppet.do.jenkins.io" })
  tags        = concat([for key, value in local.default_tags : "${key}:${value}"])
}
