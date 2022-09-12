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
