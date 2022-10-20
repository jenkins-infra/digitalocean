data "digitalocean_sizes" "k8s" {
  filter {
    key    = "regions"
    values = [var.region]
  }
}
