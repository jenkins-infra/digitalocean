terraform {
  required_version = ">= 1.12, <1.13"
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}
