resource "random_string" "suffix" {
  length  = 8
  special = false
}

locals {
  cluster_name           = lower("jenkins-infra-doks-${random_string.suffix.result}")
  public_cluster_name    = lower("jenkins-infra-doks-public-${random_string.suffix.result}")
  minimal_node_pool_size = "s-1vcpu-2gb" # Available sizes: `doctl compute size list`
  public_node_pool_size  = "s-4vcpu-8gb" # Available sizes: `doctl compute size list`
}
