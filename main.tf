#определяем провайдера
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

#корневая директория для вм и образов
resource "libvirt_pool" "pool" {
  name = "dir"
  type = "dir"
  path = "/home/flame/tfkvm"
}

#образ для клауд инит
resource "libvirt_volume" "image-cloud" {
  name   = "debian-bookworm-cloud"
  pool   = libvirt_pool.pool.name
  format = "qcow2"
  source = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
}

#основной диск ВМ
#размер 10 гигабайт, указано так для наглядности
resource "libvirt_volume" "root" {
  name           = "disk-root"
  pool           = libvirt_pool.pool.name
  base_volume_id = libvirt_volume.image-cloud.id
  size           = 10 * 1024 * 1024 * 1024
}

#конфиг клауд инит
data "template_file" "user_data" {
  template = file("./userdata-cloud-init.cfg")
}

#подключение iso в ВМ
resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  pool           = libvirt_pool.pool.name
  user_data      = data.template_file.user_data.rendered
}

#Описание ВМ
resource "libvirt_domain" "vm" {
  name       = "debian01"
  memory     = 2048
  vcpu       = 2
  qemu_agent = true
  autostart  = true
  cloudinit  = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    bridge         = "br0"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.root.id
  }

  depends_on = [ libvirt_volume.root ]
}

#Вывод имени ВМ
output "vm_name" {
  value       = libvirt_domain.vm.name
  description = "VM name"
}

#Вывод адреса ВМ
output "vm_ip" {
  value       = libvirt_domain.vm.network_interface[0].addresses.0
  description = "Interface IPs"
}