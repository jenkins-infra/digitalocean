data "digitalocean_kubernetes_versions" "doks-public" {
  version_prefix = "1.26."
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

# Configure the jenkins-infra/kubernetes-management admin service account
module "doks_public_admin_sa" {
  providers = {
    kubernetes = kubernetes.doks_public
  }
  source                     = "./.shared-tools/terraform/modules/kubernetes-admin-sa"
  cluster_name               = local.public_cluster_name
  cluster_hostname           = digitalocean_kubernetes_cluster.doks_public_cluster.kube_config.0.host
  cluster_ca_certificate_b64 = digitalocean_kubernetes_cluster.doks_public_cluster.kube_config.0.cluster_ca_certificate
}

output "kubeconfig_doks_public" {
  sensitive = true
  value     = module.doks_public_admin_sa.kubeconfig
}

data "digitalocean_loadbalancer" "doks_public" {
  name = "a04ff19a8410b4ac5a2b5c383b23a8b2"
}

output "doks_public_public_ipv4_address" {
  value = data.digitalocean_loadbalancer.doks_public.ip
}
