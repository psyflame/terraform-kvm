# Корневая директория для вм и образов, переопределяем
pool_path = "/mnt/sams465node/kubekvm"

# Устанавливаем имя образа диска виртуальных машин, и ссылку откуда качаем
cloud_image = {
  name = "debian-12-generic-amd64.qcow2"
  url = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2"
}

#конфигурация виртуальных машин мастеров
masters = {
    master01 = {name = "kube-master01", disk-name = "kube-master01.qcow2", cpu = 2, ram = 4096, disk = 10 * 1024 * 1024 * 1024, bridge = "br0"}
    master02 = {name = "kube-master02", disk-name = "kube-master02.qcow2", cpu = 2, ram = 4096, disk = 10 * 1024 * 1024 * 1024, bridge = "br0"}
}

#конфигурация виртуальных машин ингресс
vm_ingress = {
  bridge = "br0"
  cpu = 1
  ram = 2048
  disk = 10 * 1024 * 1024 * 1024
}

#конфигурация виртуальных машин воркеров
vm_worker = {
  bridge = "br0"
  cpu = 2
  ram = 4096
  disk = 20 * 1024 * 1024 * 1024
}