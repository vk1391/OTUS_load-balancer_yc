locals {
  ssh_key = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
}

resource "yandex_vpc_network" "vpc" {
  # folder_id = var.folder_id
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "public_subnet1" {
  # folder_id = var.folder_id
  v4_cidr_blocks = var.pub_subnet_cidrs1
  zone           = var.zone1
  name           = var.pub_subnet_name1
  network_id = yandex_vpc_network.vpc.id
}
resource "yandex_vpc_subnet" "public_subnet2" {
  # folder_id = var.folder_id
  v4_cidr_blocks = var.pub_subnet_cidrs2
  zone           = var.zone2
  name           = var.pub_subnet_name2
  network_id = yandex_vpc_network.vpc.id
}
resource "yandex_vpc_subnet" "private_subnet1" {
  # folder_id = var.folder_id
  v4_cidr_blocks = var.subnet_cidrs1
  zone           = var.zone1
  name           = var.subnet_name1
  network_id = yandex_vpc_network.vpc.id
  route_table_id = yandex_vpc_route_table.nat-instance-route1.id
}
resource "yandex_vpc_subnet" "private_subnet2" {
  # folder_id = var.folder_id
  v4_cidr_blocks = var.subnet_cidrs2
  zone           = var.zone2
  name           = var.subnet_name2
  network_id = yandex_vpc_network.vpc.id
  route_table_id = yandex_vpc_route_table.nat-instance-route2.id
}
resource "yandex_lb_target_group" "target_gr1" {
  name      = "tg-1"
  target {
    subnet_id = "${yandex_vpc_subnet.public_subnet1.id}"
    address   = "${yandex_compute_instance.balance_nginx1.network_interface.0.ip_address}"
}
}
resource "yandex_lb_target_group" "target_gr2" {
  name      = "tg-2"
  target {
    subnet_id = "${yandex_vpc_subnet.public_subnet2.id}"
    address   = "${yandex_compute_instance.balance_nginx2.network_interface.0.ip_address}"
}
}
resource "yandex_lb_network_load_balancer" "nlb" {
  name = "nlb"
  listener {
    name = "lst1"
    port = 80
    target_port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }
  attached_target_group {
    target_group_id = "${yandex_lb_target_group.target_gr1.id}"
    healthcheck {
      name = "test"
      http_options {
        port = 80 
      }
    }
  }
  attached_target_group {
    target_group_id = "${yandex_lb_target_group.target_gr2.id}"
    healthcheck {
      name = "test2"
      http_options {
        port = 80
      }
  }
}
}
resource "yandex_vpc_security_group" "nat-instance-sg" {
  name       = "nat-instance-sg"
  network_id = yandex_vpc_network.vpc.id

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  ingress {
    protocol       = "ICMP"
    description    = "icmp"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
  ingress {
    protocol       = "TCP"
    description    = "update"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 871
  }
  ingress {
    protocol       = "TCP"
    description    = "ftp"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 21
  }
}

resource "yandex_compute_instance" "balance_nginx1" {
  name        = var.vm_name
  hostname    = var.vm_name
  platform_id = var.platform_id
  zone        = var.zone1
  # folder_id   = var.folder_id
  resources {
    cores         = var.cpu
    memory        = var.memory
    core_fraction = var.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public_subnet1.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
    nat                = true
  }
   metadata = {
     ssh-keys           = local.ssh_key
  }
}
resource "yandex_compute_instance" "balance_nginx2" {
  name        = var.vm_name2
  hostname    = var.vm_name2
  platform_id = var.platform_id
  zone        = var.zone2
  # folder_id   = var.folder_id
  resources {
    cores         = var.cpu
    memory        = var.memory
    core_fraction = var.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public_subnet2.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
    nat                = true
  }
   metadata = {
     ssh-keys           = local.ssh_key
  }
}
resource "yandex_compute_instance" "backend_nginx1" {
  name        = var.vm_name3
  hostname    = var.vm_name3
  platform_id = var.platform_id
  zone        = var.zone1
  # folder_id   = var.folder_id
  resources {
    cores         = var.cpu
    memory        = var.memory
    core_fraction = var.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_subnet1.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
  }
   metadata = {
     ssh-keys           = local.ssh_key
  }
}
resource "yandex_compute_instance" "backend_nginx2" {
  name        = var.vm_name4
  hostname    = var.vm_name4
  platform_id = var.platform_id
  zone        = var.zone1
  # folder_id   = var.folder_id
  resources {
    cores         = var.cpu
    memory        = var.memory
    core_fraction = var.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_subnet1.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
  }
   metadata = {
     ssh-keys           = local.ssh_key
  }
}
resource "yandex_compute_instance" "backend_nginx3" {
  name        = var.vm_name5
  hostname    = var.vm_name5
  platform_id = var.platform_id
  zone        = var.zone2
  # folder_id   = var.folder_id
  resources {
    cores         = var.cpu
    memory        = var.memory
    core_fraction = var.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_subnet2.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
  }
   metadata = {
     ssh-keys           = local.ssh_key
  }
}
resource "yandex_compute_instance" "iscsi_target" {
  name        = var.vm_name6
  hostname    = var.vm_name6
  platform_id = var.platform_id
  zone        = var.zone1
  # folder_id   = var.folder_id
  resources {
    cores         = var.cpu
    memory        = var.memory
    core_fraction = var.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_subnet1.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
  }
   metadata = {
     ssh-keys           = local.ssh_key
  }
}
resource "yandex_compute_instance" "db" {
  name        = var.vm_name7
  hostname    = var.vm_name7
  platform_id = var.platform_id
  zone        = var.zone1
  # folder_id   = var.folder_id
  resources {
    cores         = var.cpu
    memory        = var.memory
    core_fraction = var.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_subnet1.id
    security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
  }
   metadata = {
     ssh-keys           = local.ssh_key
  }
}
resource "yandex_vpc_route_table" "nat-instance-route1" {
  name       = "nat-instance-route1"
  network_id = yandex_vpc_network.vpc.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.balance_nginx1.network_interface.0.ip_address
  }
}
resource "yandex_vpc_route_table" "nat-instance-route2" {
  name       = "nat-instance-route2"
  network_id = yandex_vpc_network.vpc.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.balance_nginx2.network_interface.0.ip_address
  }
}