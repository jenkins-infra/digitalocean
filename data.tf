data "digitalocean_kubernetes_versions" "k8s" {
  version_prefix = var.kubernetes_version
}

data "digitalocean_sizes" "k8s" {
  filter {
    key    = "regions"
    values = [var.region]
  }
}

output "dok8s-versions" {
  value = data.digitalocean_kubernetes_versions.k8s.valid_versions
}
