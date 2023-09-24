terraform {
  required_version = ">= 1.1, <1.2"
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    local = {
      source = "hashicorp/local"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
