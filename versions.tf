terraform {
  required_version = ">= 1.1, <1.2"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.16.0"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}
