terraform {
  required_version = ">= 1.0, <1.2"
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "1.22.2"
    }
    local = {
      source = "hashicorp/local"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
