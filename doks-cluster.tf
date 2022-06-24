resource "digitalocean_kubernetes_cluster" "doks_cluster" {
  name          = local.cluster_name
  region        = var.region
  version       = local.doks_version
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
    tags       = ["node-pool-minimal", local.cluster_name]
  }
}
