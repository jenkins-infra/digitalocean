resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  cluster_name               = lower("jenkins-infra-doks-${random_string.suffix.result}")
  public_cluster_name        = lower("jenkins-infra-doks-public-${random_string.suffix.result}")
  svcaccount_admin_name      = "infraciadmin"
  svcaccount_admin_namespace = "kube-system"
}
