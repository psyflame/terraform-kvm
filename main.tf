terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.6.14"
    }
  }
}

#для локалхоста
#для удаленного qemu+ssh://user@ip/system?keyfile=prvate-keyfile (предполагается что паблик ssh ключ проброшен)
provider "libvirt" {
    uri = "qemu:///system"
}

#пул для квм
resource "libvirt_pool" "pool" {
  name = "kubecluster"
  type = "dir"
  path = var.pool_path
}

#шаблон инициализации через клауд инит и его конфиг
data "template_file" "user_data" {
  template = file("userdata-cloud-init.cfg")
}

#создаем клауд инит образ
resource "libvirt_cloudinit_disk" "cloud_init" {
  name           = "cloud_init.iso"
  pool           = libvirt_pool.pool.name
  user_data      = data.template_file.user_data.rendered
}

#создаем образ основного диска виртуальной машины из клауд образа 
resource "libvirt_volume" "cloud_image" {
  name   = var.cloud_image.name
  pool   = libvirt_pool.pool.name
  format = "qcow2"
  source = var.cloud_image.url
}

#создаем основной диск для виртуальных машин
resource "libvirt_volume" "master-root" {
  for_each       = var.masters

  name           = each.value.disk-name
  pool           = libvirt_pool.pool.name
  base_volume_id = libvirt_volume.cloud_image.id
  size           = each.value.disk
}

#создаем виртуальные машины через for_each
resource "libvirt_domain" "master-vm" {
  for_each       = var.masters

  name       = each.value.name
  vcpu       = each.value.cpu
  memory     = each.value.ram
  qemu_agent = true
  autostart  = true
  cloudinit  = libvirt_cloudinit_disk.cloud_init.id

  network_interface {
    bridge         = each.value.bridge
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.master-root[each.key].id
  }

  depends_on = [ libvirt_volume.master-root ]

}

#выводим полученные имена виртуальных машин в гипервизоре
output "vm_name" {
  value       = values(libvirt_domain.master-vm)[*].name
  description = "VM name"
}

#выводим айпи адреса виртуальных машин в гипервизоре
output "vm_ip" {
  value       = values(libvirt_domain.master-vm)[*].network_interface[0].addresses.0
  description = "Interface IPs"
}