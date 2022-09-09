resource "digitalocean_loadbalancer" "ingress_load_balancer" {
  name   = "${local.cluster_name}-lb"
  region = var.region
  size = "lb-small"
  algorithm = "round_robin"

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"
  }

  // We define a temporary forwarding rule, since it’s necessary to create the load balancer,
  // but using ignore_changes we ignore any modifications made to it by the Kubernetes cluster.
  lifecycle {
      ignore_changes = [
        forwarding_rule,
    ]
  }
}
