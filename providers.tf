provider "digitalocean" {
  token = var.do_token
}

variable "do_token" {}

provider "local" {
}
