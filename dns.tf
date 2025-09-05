# Child DNS Zone delegated from Azure
# https://docs.digitalocean.com/products/networking/dns/getting-started/dns-registrars/
# defined as code here https://github.com/jenkins-infra/azure-net/blob/da51f9ddc012e4cb0eed6299917b7be22db249c2/dns-records.tf#L487-L497
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

resource "digitalocean_record" "usage_ipv4" {
  domain = digitalocean_domain.do_jenkins_io.id
  type   = "A"
  name   = "usage"
  value  = digitalocean_droplet.usage_jenkins_io.ipv4_address
}

resource "digitalocean_record" "usage_ipv6" {
  domain = digitalocean_domain.do_jenkins_io.id
  type   = "AAAA"
  name   = "usage"
  value  = digitalocean_droplet.usage_jenkins_io.ipv6_address
}
