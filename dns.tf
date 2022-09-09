resource "digitalocean_domain" "top_level_domains" {
  for_each = toset(var.top_level_domains)
  name     = each.value
}

resource "digitalocean_record" "a_records" {
  for_each = toset(var.top_level_domains)
  domain   = each.id
  type     = "A"
  ttl      = 60
  name     = "@"
  value    = digitalocean_loadbalancer.ingress_load_balancer.ip
}

resource "digitalocean_record" "cname_redirects" {
  for_each = toset(var.top_level_domains)
  domain   = each.value.id
  type     = "CNAME"
  ttl      = 60
  name     = "www"
  value    = "@"
}
