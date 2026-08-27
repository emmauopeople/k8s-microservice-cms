variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster. Null lets AWS use its current default supported version."
  type        = string
  default     = null
}

variable "cluster_subnet_ids" {
  description = "Subnet IDs used by the EKS control plane."
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "Private subnet IDs used by EKS managed node groups."
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Enable private API endpoint access."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API endpoint access."
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to access the public EKS API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types sent to CloudWatch Logs."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_days" {
  description = "Retention period for EKS control plane logs."
  type        = number
  default     = 7
}

variable "node_group_name" {
  description = "Managed node group name."
  type        = string
  default     = "system"
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "Capacity type for the managed node group."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "Worker node root volume size in GiB."
  type        = number
  default     = 30
}

variable "cluster_addons" {
  description = "EKS managed add-ons to install."
  type        = set(string)
  default     = ["vpc-cni", "kube-proxy", "coredns"]
}

variable "cluster_addon_configuration_values" {
  description = "Optional JSON configuration values keyed by EKS managed add-on name."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default     = {}
}
