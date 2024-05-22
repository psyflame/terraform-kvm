# Корневая директория для вм и образов
variable "pool_path" {
  type    = string
  default = "/var/lib/libvirt/"
}

# Образ для cloud init
variable "cloud_image" {
  type = object({
    name = string
    url  = string
  })
}

# Переменная списка виртуальных машин Мастер
variable "masters" {
  type = map(object({
    name = string
    cpu = number
    ram = number
    disk = number
    disk-name = string
    bridge = string
  }))
}

# Переменная списка виртуальных машин Ингресс
variable "vm_ingress" {
  type = object({
    cpu    = number
    ram    = number
    disk   = number
    bridge = string
  })
}

# Переменная списка виртуальных машин Воркер
variable "vm_worker" {
  type = object({
    cpu    = number
    ram    = number
    disk   = number
    bridge = string
  })
}
