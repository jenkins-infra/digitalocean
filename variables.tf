variable "region" {
  type        = string
  default     = "fra1"
  description = "DOKS region (availables regions: `doctl kubernetes options regions`)"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.20"
  description = "Kubernetes version in format '<MINOR>.<MINOR>'"
}

variable "autoscaled_node_pool_size" {
  type        = string
  default     = "s-2vcpu-4gb"
  description = "Autoscaled node pool size (available sizes: `doctl compute size list`)"
}

variable "autoscaled_node_pool_max_nodes" {
  type        = number
  default     = 2
  description = "Autoscaled node pool max nodes count"
}

variable "auto_upgrade" {
  type        = bool
  default     = false
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
