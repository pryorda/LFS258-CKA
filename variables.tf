# VSphere variables
variable "vsphere_network_label" {
  description = "vSphere Network Name"
  default     = "VM Network"
}

variable "vsphere_network_domain_search" {
  description = "vSphere DNS Search Domains (comma-delimited, no spaces)"
  default     = "pryorda.net"
}

variable "vsphere_datacenter" {
  description = "The VSphere Datacenter used in provisioning"
  default     = "p.net"
}

variable "vsphere_cluster" {
  description = "The VSphere Cluster used in provisioning"
  default     = "c1"
}

variable "vsphere_vcpu" {
  description = "The number of CPUS for the servers"
  default     = "8"
}

variable "vsphere_memory" {
  description = "The amount of memory for the servers"
  default     = "8192"
}

variable "vsphere_cluster_timezone" {
  description = "The timezone that is set for the servers"
  default     = "America/Denver"
}

variable "vsphere_datastore" {
  description = "The backend datastore used for provisioning the disk"
  default     = "NVMe_1"
}

variable "vsphere_folder_path" {
  description = "The folder path in vsphere that the server will be created in"
  default     = "Kube"
}

variable "vsphere_reserved_memory" {
  description = "MB of memory that will be reserved for the virtual machine"
  default     = 0
}

variable "sync_time_with_host" {
  description = "Sync time with the guest OS from host"
  default     = true
}

variable "vsphere_username" {
  description = "vSphere username"
}

variable "vsphere_password" {
  description = "vSphere Password"
}

