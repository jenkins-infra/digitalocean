terraform {
  required_version = ">= 1.9, <1.10"
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}
