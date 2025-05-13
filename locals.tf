locals {
  # Ref. https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-githubs-ip-addresses
  # Only IPv4
  # TODO track with updatecli
  github_ips = {
    webhooks = ["140.82.112.0/20", "143.55.64.0/20", "185.199.108.0/22", "192.30.252.0/22"]
  }
  default_tags = {
    scope                    = "terraform-managed"
    jenkins_infra_repository = "digitalocean"
  }
}
