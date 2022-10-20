data "digitalocean_kubernetes_versions" "doks-public" {
  version_prefix = "1.23."
}

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

  # One node pool with autoscalling
  node_pool {
    name       = "public-node-pool"
    size       = local.public_node_pool_size
    auto_scale = true
    min_nodes  = 1
    max_nodes  = var.autoscaled_node_pool_max_nodes
    tags       = ["public-node-pool", local.public_cluster_name]
  }
}
