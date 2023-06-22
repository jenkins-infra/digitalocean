data "digitalocean_kubernetes_versions" "doks-public" {
  version_prefix = "1.24."
}

resource "digitalocean_kubernetes_cluster" "doks_public_cluster" {
  name   = local.public_cluster_name
  region = var.region
  # `doctl kubernetes options versions` doesn't return anything if the minor k8s version isn't supported anymore, note it can fail the build.
  version       = data.digitalocean_kubernetes_versions.doks-public.latest_version
  auto_upgrade  = true
  surge_upgrade = true
  ha            = true
  tags          = ["managed-by:terraform"]
  lifecycle {
    ignore_changes = [
      updated_at,
    ]
  }

  maintenance_policy {
    start_time = "06:00"
    day        = "sunday"
  }

  # One node pool with autoscalling
  node_pool {
    name       = "public-node-pool"
    size       = "s-4vcpu-8gb" # Available sizes: `doctl compute size list`
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 4
    tags       = ["public-node-pool", local.public_cluster_name]
  }
}
