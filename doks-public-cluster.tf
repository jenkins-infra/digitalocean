data "digitalocean_kubernetes_versions" "doks-public" {
  version_prefix = "1.27."
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

provider "kubernetes" {
  alias                  = "doks_public"
  host                   = digitalocean_kubernetes_cluster.doks_public_cluster.kube_config.0.host
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.doks_public_cluster.kube_config.0.cluster_ca_certificate)
  # Bootstrap requires to use the DigitalOcean API user as no service account or technical user are created in the cluster
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "doctl"
    args = ["kubernetes", "cluster", "kubeconfig", "exec-credential",
    "--version=v1beta1", digitalocean_kubernetes_cluster.doks_public_cluster.id]
  }
}
