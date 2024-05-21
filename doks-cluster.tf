data "digitalocean_kubernetes_versions" "doks" {
  version_prefix = "1.27."
}

resource "digitalocean_kubernetes_cluster" "doks_cluster" {
  name   = local.cluster_name
  region = var.region
  # `doctl kubernetes options versions` doesn't return anything if the minor k8s version isn't supported anymore, note it can fail the build.
  version       = data.digitalocean_kubernetes_versions.doks.latest_version
  auto_upgrade  = true
  surge_upgrade = true
  ha            = true
  tags          = ["managed-by:terraform"]

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
}

provider "kubernetes" {
  alias                  = "doks"
  host                   = digitalocean_kubernetes_cluster.doks_cluster.kube_config.0.host
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.doks_cluster.kube_config.0.cluster_ca_certificate)
  # Bootstrap requires to use the DigitalOcean API user as no service account or technical user are created in the cluster
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "doctl"
    args = ["kubernetes", "cluster", "kubeconfig", "exec-credential",
    "--version=v1beta1", digitalocean_kubernetes_cluster.doks_cluster.id]
  }
}
