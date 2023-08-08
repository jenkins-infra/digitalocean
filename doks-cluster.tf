data "digitalocean_kubernetes_versions" "doks" {
  version_prefix = "1.25."
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

# Data source required to configure the kubernetes provider as per https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/kubernetes_cluster#kubernetes-terraform-provider-example
data "digitalocean_kubernetes_cluster" "doks" {
  name       = local.cluster_name
  depends_on = [digitalocean_kubernetes_cluster.doks_cluster]
}
provider "kubernetes" {
  alias                  = "doks"
  host                   = data.digitalocean_kubernetes_cluster.doks.kube_config.0.host
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.doks.kube_config.0.cluster_ca_certificate)
  # Bootstrap requires to use the DigitalOcean API user as no service account or technical user are created in the cluster
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "doctl"
    args = ["kubernetes", "cluster", "kubeconfig", "exec-credential",
    "--version=v1beta1", data.digitalocean_kubernetes_cluster.doks.id]
  }
}

# Configure the jenkins-infra/kubernetes-management admin service account
resource "kubernetes_service_account_v1" "doks_infraciadmin" {
  provider = kubernetes.doks
  metadata {
    name      = local.svcaccount_admin_name
    namespace = local.svcaccount_admin_namespace
  }
  automount_service_account_token = "false"
}
resource "kubernetes_secret_v1" "doks_infraciadmin_token" {
  provider = kubernetes.doks
  metadata {
    name      = "${local.svcaccount_admin_name}-token"
    namespace = local.svcaccount_admin_namespace
    annotations = {
      "kubernetes.io/service-account.name" = "${local.svcaccount_admin_name}"
    }
  }
  type = "kubernetes.io/service-account-token"
}
resource "kubernetes_cluster_role_binding" "doks_infraciadmin_clusteradmin" {
  provider = kubernetes.doks
  metadata {
    name = "${local.svcaccount_admin_name}_clusteradmin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = local.svcaccount_admin_name
    namespace = local.svcaccount_admin_namespace
  }
}

output "kubeconfig_doks" {
  sensitive = true
  value     = <<-EOF
  apiVersion: v1
  kind: Config
  clusters:
    - name: ${local.cluster_name}
      cluster:
        certificate-authority-data: ${data.digitalocean_kubernetes_cluster.doks.kube_config.0.cluster_ca_certificate}
        server: ${data.digitalocean_kubernetes_cluster.doks.kube_config.0.host}
  contexts:
    - name: ${local.svcaccount_admin_name}@${local.cluster_name}
      context:
        cluster: ${local.cluster_name}
        namespace: ${local.svcaccount_admin_namespace}
        user: ${local.svcaccount_admin_name}
  users:
    - name: ${local.svcaccount_admin_name}
      user:
        token: ${lookup(kubernetes_secret_v1.doks_infraciadmin_token.data, "token")}
  current-context: ${local.svcaccount_admin_name}@${local.cluster_name}
  EOF
}
