data "digitalocean_kubernetes_versions" "doks" {
  version_prefix = "1.24."
}

resource "digitalocean_kubernetes_cluster" "doks_cluster" {
  name   = local.cluster_name
  region = var.region
  # `doctl kubernetes options versions` doesn't return anything if the minor k8s version isn't supported anymore, note it can fail the build.
  version       = data.digitalocean_kubernetes_versions.doks.latest_version
  auto_upgrade  = var.auto_upgrade
  surge_upgrade = true
  tags          = ["managed-by:terraform"]
  lifecycle {
    ignore_changes = [
      updated_at,
    ]
  }

  maintenance_policy {
    start_time = var.maintenance_policy_start_time
    day        = var.maintenance_policy_day
  }

  # Small node pool without autoscalling.
  # As we can't scale to 0 with DO, we're setting up 2 node pools:
  # - this one with the minimal size and no heavy usage
  # - another beefy one with autoscalling enabled, see ./autoscaled-node-pool.tf
  node_pool {
    name       = "minimal-node-pool"
    size       = local.minimal_node_pool_size
    auto_scale = false
    node_count = 1
    tags       = ["minimal-node-pool", local.cluster_name]
  }
}

resource "digitalocean_kubernetes_node_pool" "autoscaled-pool" {
  count      = var.autoscaled_node_pool_enabled ? 1 : 0
  cluster_id = digitalocean_kubernetes_cluster.doks_cluster.id
  name       = "autoscaled-node-pool"
  size       = var.autoscaled_node_pool_size
  auto_scale = true
  min_nodes  = 1
  max_nodes  = var.autoscaled_node_pool_max_nodes
  tags       = ["node-pool-autoscaled", local.cluster_name]
  lifecycle {
    ignore_changes = [
      node_count,
      actual_node_count,
      nodes,
    ]
  }
}
