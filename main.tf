terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = ">=2.0"
    }
  }
}

provider "vsphere" {
  user     = var.username
  password = var.password
  vsphere_server = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
    name = "blinkenlights"
}

data "vsphere_resource_pool" "rp" {
  name = "lab-workload"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "vsan" {
  name = "datastore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "vmnet" {
  name = "Labmonkeys-Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_folder" "dev_folder" {
  path = var.parent_folder
}

resource "vsphere_folder" "parent" {
  path = var.parent_folder
  type = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "hzn-core-vm" {
  name = "hzn-core"
  resource_pool_id = data.vsphere_resource_pool.rp.id
  datastore_id = data.vsphere_datastore.vsan.id
  folder = data.vsphere_folder.dev_folder.path

  num_cpus = 2
  memory = 4096
  guest_id = "ubuntu64Guest"
  wait_for_guest_net_timeout = 0

  disk {
    label = "disk0"
    size = 30
  }

  network_interface {
    network_id = data.vsphere_network.vmnet.id
  }
}