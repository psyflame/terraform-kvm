# Terraform + KVM

- и cloudinit 
- Пока что минимум переменных и минимум файлов :)

## Нам потребуется

1. Linux хост с рабочим kmv\qemu\libvirt. На момент написания я использовал дебиан 12
2. Маршрутизатор который выдает ip адреса для виртуалок и имеет доступ в интернет
3. Впн для скачивания терраформа и его плагинов

## Установим терраформ на дебиан

1. wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

2. echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

3. sudo apt update && sudo apt install terraform

4. terraform -install-autocomplete  (Добавляем автокомплит и перелогиниваемся) </br>

## Клонируем репозиторий и настраиваем

- Все блоки в файле main.tf подписаны комментариями. Особое внимание можно обратить на "libvirt_pool" "pool", куда положим нашу вм и все нужные файлы

- В файле userdata-cloud-init.cfg можно исправить например пароль, добавить пакеты для установки

## Переходим в директорию куда склонировали репозиторий и запускаем

1. terraform init 
- потребуется впн, иначе не скачает плагины
2. terraform plan 
- смотрим что изменится, шаг не обязательный
3. terraform apply 
- применяем наш манифест
- вывод будет примерно таким:

```
libvirt_pool.pool: Creating...
libvirt_pool.pool: Creation complete after 5s [id=3dea73f3-8aa5-4f97-a066-71e5e12ba98d]
libvirt_cloudinit_disk.commoninit: Creating...
libvirt_volume.image-cloud: Creating...
libvirt_cloudinit_disk.commoninit: Still creating... [10s elapsed]
libvirt_volume.image-cloud: Still creating... [10s elapsed]
libvirt_volume.image-cloud: Creation complete after 15s [id=/home/flame/tfkvm/debian-bookworm-cloud]
libvirt_cloudinit_disk.commoninit: Creation complete after 15s [id=/home/flame/tfkvm/commoninit.iso;bed08c7b-37cd-4294-b9ed-a60d07dc6cce]
libvirt_volume.root: Creating...
libvirt_volume.root: Creation complete after 0s [id=/home/flame/tfkvm/disk-root]
libvirt_domain.vm: Creating...
libvirt_domain.vm: Still creating... [10s elapsed]
libvirt_domain.vm: Still creating... [20s elapsed]
libvirt_domain.vm: Still creating... [30s elapsed]
libvirt_domain.vm: Creation complete after 36s [id=c77eed40-9d50-49bd-8627-b18e25beb7e5]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

vm_ip = "192.168.88.169"
vm_name = "debian01"

```
4. ssh linux@192.168.88.169
- подключаемся к вм и проверяем

## Устрой дестрой

1. terraform destroy -target=libvirt_volume.root 
- удалит диск и вм, останется скачанный образ вм и другие ресурсы
2. terraform destroy 
- удалить всё что создали

## Решение проблем

1. Could not open '/var/lib/libvirt/images/<FILE_NAME>': Permission denied` errors.

- В файле /etc/libvirt/qemu.conf указать `security_driver = "none"`