resource "digitalocean_domain" "default" {
  name = var.domain_name
}

resource "digitalocean_record" "a_record" {
  domain = digitalocean_domain.default.id
  type   = "A"
  ttl    = 60
  name   = "@"
  value  = digitalocean_loadbalancer.ingress_load_balancer.ip
}

resource "digitalocean_record" "cname_redirect" {
  domain = digitalocean_domain.default.id
  type   = "CNAME"
  ttl    = 60
  name   = "www"
  value  = "@"
}
