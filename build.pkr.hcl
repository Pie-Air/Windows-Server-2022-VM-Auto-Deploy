variable "vsphere_server" {}
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_datastore" {}
variable "vsphere_network" {}
variable "vm_name" {}
variable "vm_cpu_num" {}
variable "vm_mem_size" {}
variable "vm_disk_size" {}
variable "winadmin_password" {}
variable "os_iso_path" {}

build {
  name = "vsphere-iso-build"

  sources = ["source.vsphere-iso.vsphere-iso-source"]

  provisioner "windows-shell" {
    inline = ["ipconfig"]
  }
}

source "vsphere-iso" "vsphere-iso-source" {
  vcenter_server       = var.vsphere_server
  username             = var.vsphere_user
  password             = var.vsphere_password
  insecure_connection  = true
  host                 = var.vsphere_server

  datastore            = var.vsphere_datastore

  communicator         = "winrm"
  winrm_username       = "Administrator"
  winrm_password       = var.winadmin_password

  convert_to_template  = true

  vm_name              = var.vm_name
  guest_os_type        = "windows9Server64Guest"

  CPUs                 = var.vm_cpu_num
  RAM                  = var.vm_mem_size
  RAM_reserve_all      = true
  firmware             = "bios"

  disk_controller_type = ["lsilogic-sas"]

  storage {
    disk_size             = var.vm_disk_size
    disk_thin_provisioned = true
  }

  network_adapters {
    network      = var.vsphere_network
    network_card = "vmxnet3"
  }

  iso_paths = [
    var.os_iso_path,
    "[] /vmimages/tools-isoimages/windows.iso"
  ]

  floppy_files = [
    "autounattend.xml",
    "./scripts/disable-network-discovery.cmd",
    "./scripts/enable-rdp.cmd",
    "./scripts/enable-winrm.ps1",
    "./scripts/install-vm-tools.cmd",
    "./scripts/set-temp.ps1"
  ]
}