data "digitalocean_kubernetes_versions" "doks-public" {
  version_prefix = "1.25."
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
  lifecycle {
    ignore_changes = [
      updated_at,
    ]
  }

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

# Data source required as per https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/kubernetes_cluster#kubernetes-terraform-provider-example
# To configure the kuberenetes provider
data "digitalocean_kubernetes_cluster" "doks_public" {
  name       = local.public_cluster_name
  depends_on = [digitalocean_kubernetes_cluster.doks_public_cluster]
}
provider "kubernetes" {
  alias                  = "doks_public"
  host                   = data.digitalocean_kubernetes_cluster.doks_public.kube_config.0.host
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.doks_public.kube_config.0.cluster_ca_certificate)
  # Bootstrap requires to use the Digital Ocean API user as no service account or technical user are created in the cluster
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "doctl"
    args = ["kubernetes", "cluster", "kubeconfig", "exec-credential",
    "--version=v1beta1", data.digitalocean_kubernetes_cluster.doks_public.id]
  }
}

# Configure the jenkins-infra/kubernetes-management admin service account
resource "kubernetes_service_account_v1" "doks_public_infraciadmin" {
  provider = kubernetes.doks_public
  metadata {
    name      = local.svcaccount_admin_name
    namespace = local.svcaccount_admin_namespace
  }
  automount_service_account_token = "false"
}
resource "kubernetes_secret_v1" "doks_public_infraciadmin_token" {
  provider = kubernetes.doks_public
  metadata {
    name      = "${local.svcaccount_admin_name}-token"
    namespace = local.svcaccount_admin_namespace
    annotations = {
      "kubernetes.io/service-account.name" = "${local.svcaccount_admin_name}"
    }
  }
  type = "kubernetes.io/service-account-token"
}
resource "kubernetes_cluster_role_binding" "doks_public_infraciadmin_clusteradmin" {
  provider = kubernetes.doks_public
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

output "kubeconfig_doks_public" {
  sensitive = true
  value     = <<-EOF
  apiVersion: v1
  kind: Config
  clusters:
    - name: ${local.public_cluster_name}
      cluster:
        certificate-authority-data: ${data.digitalocean_kubernetes_cluster.doks_public.kube_config.0.cluster_ca_certificate}
        server: ${data.digitalocean_kubernetes_cluster.doks_public.kube_config.0.host}
  contexts:
    - name: ${local.svcaccount_admin_name}@${local.public_cluster_name}
      context:
        cluster: ${local.public_cluster_name}
        namespace: ${local.svcaccount_admin_namespace}
        user: ${local.svcaccount_admin_name}
  users:
    - name: ${local.svcaccount_admin_name}
      user:
        token: ${lookup(kubernetes_secret_v1.doks_public_infraciadmin_token.data, "token")}
  current-context: ${local.svcaccount_admin_name}@${local.public_cluster_name}
  EOF
}
