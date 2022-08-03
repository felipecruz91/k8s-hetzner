variable "hcloud_token" {
  default     = ""
  description = "Hetzner Cloud API token"
}

# Master node vars
variable "master_name" {
  default     = "master"
  description = "Name of the master node"
}

variable "master_server_type" {
  default     = "cpx11"
  description = "Server type of the master node"
}

variable "master_location" {
  default     = "nbg1"
  description = "Location of the master node"
}

# Worker nodes vars (docker)
variable "worker_nodes_count" {
  default     = 3
  description = "Number of worker nodes (docker)"
}

variable "worker_server_type" {
  default     = "cx11"
  description = "Server type of the worker nodes (docker)"
}

variable "worker_location" {
  default     = "nbg1"
  description = "Location of the worker nodes (docker)"
}

# Worker nodes vars (containerd)
variable "worker_containerd_server_type" {
  default     = "cx11"
  description = "Server type of the worker nodes (containerd)"
}

variable "worker_containerd_location" {
  default     = "nbg1"
  description = "Location of the worker nodes (containerd)"
}

variable "worker_nodes_containerd_count" {
  default     = 0
  description = "Number of worker nodes (containerd)"
}

variable "ssh_identity" {
  default     = "~/.ssh/id_rsa"
  description = "SSH identity, used to copy keys"
  type        = string
}
