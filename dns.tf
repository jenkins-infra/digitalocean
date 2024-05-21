# Child DNS Zone delegated from Azure
# https://docs.digitalocean.com/products/networking/dns/getting-started/dns-registrars/
resource "digitalocean_domain" "do_jenkins_io" {
  name = "do.jenkins.io"
}

resource "digitalocean_record" "archives_ipv4" {
  domain = digitalocean_domain.do_jenkins_io.id
  type   = "A"
  name   = "archives"
  value  = digitalocean_droplet.archives_jenkins_io.ipv4_address
}

resource "digitalocean_record" "archives_ipv6" {
  domain = digitalocean_domain.do_jenkins_io.id
  type   = "AAAA"
  name   = "archives"
  value  = digitalocean_droplet.archives_jenkins_io.ipv6_address
}
