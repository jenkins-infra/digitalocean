resource "digitalocean_kubernetes_cluster" "doks_public_cluster" {
  name          = local.public_cluster_name
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

  # Small node pool with autoscalling
  node_pool {
    name       = "minimal-node-pool"
    size       = local.minimal_node_pool_size
    auto_scale = true
    min_nodes  = 1
    max_nodes  = var.autoscaled_node_pool_max_nodes
    tags       = ["node-pool-minimal", local.cluster_name]
  }
}
