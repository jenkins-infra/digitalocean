resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  cluster_name           = lower("jenkins-infra-doks-${random_string.suffix.result}")
  # `doctl kubernetes options versions` doesn't return anything if the linor k8s version isn't suported anymore.
  # hardoding the version until we switch to Kubernetes 1.21
  doks_version           = "1.20.15-do.1"
  # doks_version           = data.digitalocean_kubernetes_versions.k8s.latest_version
  minimal_node_pool_size = "s-1vcpu-2gb" # Available sizes: `doctl compute size list`
}
