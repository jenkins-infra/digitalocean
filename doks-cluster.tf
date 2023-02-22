data "digitalocean_kubernetes_versions" "doks" {
  version_prefix = "1.24."
}

resource "digitalocean_kubernetes_cluster" "doks_cluster" {
  name   = local.cluster_name
  region = var.region
  # `doctl kubernetes options versions` doesn't return anything if the minor k8s version isn't supported anymore, note it can fail the build.
  version       = data.digitalocean_kubernetes_versions.doks.latest_version
  auto_upgrade  = true
  surge_upgrade = true
  tags          = ["managed-by:terraform"]
  lifecycle {
    ignore_changes = [
      updated_at,
    ]
  }

  maintenance_policy {
    start_time = "04:00"
    day        = "sunday"
  }

  # Small node pool without autoscalling.
  # As we can't scale to 0 with DO, we're setting up 2 node pools:
  # - this one with the minimal size and no heavy usage
  # - another beefy one with autoscalling enabled, see ./autoscaled-node-pool.tf
  node_pool {
    name       = "minimal-node-pool"
    size       = "s-1vcpu-2gb" # Available sizes: `doctl compute size list`
    auto_scale = false
    node_count = 1
    tags       = ["minimal-node-pool", local.cluster_name]
  }
}

resource "digitalocean_kubernetes_node_pool" "autoscaled-pool" {
  cluster_id = digitalocean_kubernetes_cluster.doks_cluster.id
  name       = "autoscaled-node-pool"
  # CPU optimized, 16vCPU/32GB (at 2022/02/17)
  size       = "c-16" # available sizes: `doctl compute size list`
  auto_scale = true
  min_nodes  = 1
  max_nodes  = 50
  tags       = ["node-pool-autoscaled", local.cluster_name]
  lifecycle {
    ignore_changes = [
      node_count,
      actual_node_count,
      nodes,
    ]
  }
}
