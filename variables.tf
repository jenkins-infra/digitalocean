variable "region" {
  type        = string
  default     = "fra1"
  description = "DOKS region (availables regions: `doctl kubernetes options regions`)"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.22."
  description = "Kubernetes version in format '<MAJOR>.<MINOR>.'"
}

variable "autoscaled_node_pool_size" {
  type        = string
  default     = "c-16" # CPU optimized, 16vCPU/32GB (at 2022/02/17)
  description = "Autoscaled node pool size (available sizes: `doctl compute size list`)"
}

variable "autoscaled_node_pool_max_nodes" {
  type        = number
  default     = 10
  description = "Autoscaled node pool max nodes count"
}

variable "auto_upgrade" {
  type        = bool
  default     = true
  description = "Activate Digital Ocean cluster auto-upgrade for path versions"
}

variable "maintenance_policy_start_time" {
  type        = string
  default     = "04:00"
  description = "Auto-upgrade maintenance policy start time"
}

variable "maintenance_policy_day" {
  type        = string
  default     = "sunday"
  description = "Auto-upgrade maintenance policy start time"
}

variable "domain_name" {
  description = "Domain to create records and pods for"
  default     = ["do.jenkins.io"]
  type        = string
}
