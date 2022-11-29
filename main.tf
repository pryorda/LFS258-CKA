# Commands to import ova and mark as template
# Import OVA: GOVC_DATACENTER=dc1 GOVC_INSECURE=true GOVC_URL=dpryor:'WEEE'@dc1.pryorda.net govc import.ova -ds=tools -folder=Devs  -host=dc1.pryorda.net -name=focal_current https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.ova
# Template: GOVC_DATACENTER=dc1 GOVC_INSECURE=true GOVC_URL=dpryor:'WEEEE'@dc1.pryorda.net govc vm.markastemplate focal_current
# Reference: https://giedrius.blog/2018/04/23/terraform-vsphere-provider-1-x-now-supports-deploying-ova-files-makes-using-ovftool-on-esxi-hosts-obsolete/

provider "vsphere" {
  user           = var.vsphere_username
  password       = var.vsphere_password
  vsphere_server = "vmware-vcenter.pryorda.net"


  # If you have a self-signed cert
  allow_unverified_ssl = true
}

resource "random_string" "unique-name" {
  length  = 8
  upper   = false
  numeric = false
  lower   = true
  special = false
}

#locals {
#  host_basename = replace(coalesce(
#    var.hostname_override,
#    "${var.vsphere_username}-${random_string.unique-name.result}",
#  ), ".", "")
#}

resource "vsphere_folder" "kube" {
  path          = "/Kube"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.vsphere_cluster}/Resources"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network_label
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_host" "host" {
  name          = "vmware-hypervisor1.pryorda.net"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# Instance Resource
resource "vsphere_virtual_machine" "worker" {
  count            = 2
  name             = "kube-worker-${count.index + 1}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  datacenter_id    = data.vsphere_datacenter.datacenter.id
  host_system_id   = data.vsphere_host.host.id
  folder           = var.vsphere_folder_path

  wait_for_guest_net_timeout = 180
  wait_for_guest_ip_timeout  = 180

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "disk0"
    size             = "100"
    thin_provisioned = true
  }

  ovf_deploy {
    remote_ovf_url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.ova"
  }

  /*
  Valid Propeties
  user-data (encoded)
  public-keys
  password
  instance-id (unique)
  hostname
  seedfrom (url containing userdata)
 */

  vapp {
    properties = {
      hostname  = "kube-worker-${count.index + 1}"
      user-data = base64encode(file("${path.module}/cloud-init.tpl"))
    }
  }

  cdrom {
    client_device = true
  }

  num_cpus           = var.vsphere_vcpu
  memory             = var.vsphere_memory
  memory_reservation = var.vsphere_reserved_memory

  enable_disk_uuid    = true
  sync_time_with_host = var.sync_time_with_host

  # Prevent attributes from going null in 0.12
  custom_attributes = {}
  extra_config      = {}
  tags              = []

  lifecycle {
    ignore_changes = [
      disk,
      poweron_timeout,
      ide_controller_count,
      sata_controller_count,
    ]
  }
  depends_on = [vsphere_folder.kube]
}

# Instance Resource
resource "vsphere_virtual_machine" "controller" {
  count            = 2
  name             = "kube-controller-${count.index + 1}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  datacenter_id    = data.vsphere_datacenter.datacenter.id
  host_system_id   = data.vsphere_host.host.id
  folder           = var.vsphere_folder_path

  wait_for_guest_net_timeout = 180
  wait_for_guest_ip_timeout  = 180


  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "disk0"
    size             = "100"
    thin_provisioned = true
  }

  ovf_deploy {
    remote_ovf_url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.ova"
  }

  /*
  Valid Propeties
  user-data (encoded)
  public-keys
  password
  instance-id (unique)
  hostname
  seedfrom (url containing userdata)
  */

  vapp {
    properties = {
      hostname  = "kube-controller-${count.index + 1}"
      user-data = base64encode(file("${path.module}/cloud-init.tpl"))
    }
  }

  cdrom {
    client_device = true
  }

  num_cpus           = var.vsphere_vcpu
  memory             = var.vsphere_memory
  memory_reservation = var.vsphere_reserved_memory

  enable_disk_uuid    = true
  sync_time_with_host = var.sync_time_with_host

  # Prevent attributes from going null in 0.12
  custom_attributes = {}
  extra_config      = {}
  tags              = []

  lifecycle {
    ignore_changes = [
      disk,
      poweron_timeout,
      ide_controller_count,
      sata_controller_count,
    ]
  }
  depends_on = [vsphere_folder.kube]
}

output "worker_private_ips" {
  value      = vsphere_virtual_machine.worker.*.default_ip_address
  depends_on = [vsphere_virtual_machine.worker]
}
output "controller_private_ips" {
  value      = vsphere_virtual_machine.controller.*.default_ip_address
  depends_on = [vsphere_virtual_machine.controller]
}
