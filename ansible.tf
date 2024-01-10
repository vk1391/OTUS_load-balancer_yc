resource "local_file" "inventory" {
  content = <<-DOC
---

all:
  children:
    nginx_balance:
      hosts:
        front1:
          ansible_host: "${yandex_compute_instance.balance_nginx1.network_interface.0.nat_ip_address}"
          ansible_private_key_file: "~/.ssh/id_rsa.pub"
        front2:
          ansible_host: "${yandex_compute_instance.balance_nginx2.network_interface.0.nat_ip_address}"
          ansible_private_key_file: "~/.ssh/id_rsa.pub"     
    pcs_servers:
      hosts:
        pcs1:
          ansible_host: "${yandex_compute_instance.backend_nginx1.network_interface.0.ip_address}" 
          ansible_private_key_file: "~/.ssh/id_rsa.pub"
        pcs2:
          ansible_host: "${yandex_compute_instance.backend_nginx2.network_interface.0.ip_address}" 
          ansible_private_key_file: "~/.ssh/id_rsa.pub"       
        pcs3:
          ansible_host: "${yandex_compute_instance.backend_nginx3.network_interface.0.ip_address}" 
          ansible_private_key_file: "~/.ssh/id_rsa.pub"    
       
    iscsi_server:
      hosts:
        iscsi:
          ansible_host: "${yandex_compute_instance.iscsi_target.network_interface.0.ip_address}" 
          ansible_private_key_file: "~/.ssh/id_rsa.pub"

    db:
      hosts:
        db:
          ansible_host: "${yandex_compute_instance.db.network_interface.0.ip_address}"
          ansible_private_key_file: "~/.ssh/id_rsa.pub"
            
  vars:
    domain: "mydomain.test"
    ntp_timezone: "UTC"
    pcs_password: "strong_pass" # cluster user: hacluster
    cluster_name: "hacluster"
    iqn_server: "iqn.2024-01.ru.otus:storage.target00"
    ip_pcs1: "${yandex_compute_instance.backend_nginx1.network_interface.0.ip_address}" 
    ip_pcs2: "${yandex_compute_instance.backend_nginx2.network_interface.0.ip_address}"
    ip_pcs3: "${yandex_compute_instance.backend_nginx3.network_interface.0.ip_address}" 
...
    DOC
  filename = "./ansible/inventory.yaml"



  depends_on = [
    yandex_lb_network_load_balancer.nlb
  ]
}
resource "local_file" "ssh_jump_env" {
  content = <<-DOC
---
ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -q centos@"${yandex_compute_instance.balance_nginx1.network_interface.0.nat_ip_address}""'
...
    DOC
  filename = "./ansible/group_vars/all/vars.yml"
    depends_on = [
    local_file.inventory
    ]
}

resource "local_file" "nginx_file1"{
  content = <<-DOC
upstream backend {
	server ${yandex_compute_instance.backend_nginx1.network_interface.0.ip_address};
	server ${yandex_compute_instance.backend_nginx2.network_interface.0.ip_address};
  server ${yandex_compute_instance.backend_nginx3.network_interface.0.ip_address};
}

server {
	listen 80;
	server_name ${yandex_compute_instance.balance_nginx1.network_interface.0.nat_ip_address};
	
location / {
  proxy_pass http://backend;
	}
 }
    DOC
  filename = "default"

  depends_on = [
    local_file.ssh_jump_env
  ]
}
resource "local_file" "nginx_file2"{
  content = <<-DOC
upstream backend {
	server ${yandex_compute_instance.backend_nginx1.network_interface.0.ip_address};
	server ${yandex_compute_instance.backend_nginx2.network_interface.0.ip_address};
  server ${yandex_compute_instance.backend_nginx3.network_interface.0.ip_address};
}

server {
	listen 80;
	server_name ${yandex_compute_instance.balance_nginx2.network_interface.0.nat_ip_address};
	
location / {
  proxy_pass http://backend;
	}
 }
    DOC
  filename = "default2"

  depends_on = [
    local_file.nginx_file1
  ]
}
resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 20"
  }

  depends_on = [
    local_file.nginx_file2
  ]
}
resource "null_resource" "ansible_nginx" {
  provisioner "local-exec" {
    command = "ansible-playbook -u centos -i ./ansible/inventory.yaml ./ansible/main.yml"
  }
  depends_on = [
    null_resource.wait
  ]
}
#  resource "null_resource" "ansible_nginx_uwsgi" {
#    provisioner "local-exec" {
#      command = "git clone https://github.com/vk1391/ansible-nginx-uwsgi.git"
#    }
#    depends_on = [
#      null_resource.ansible_nginx
#    ]
#  }
#  resource "null_resource" "ansible_nginx_uwsgi_install" {
#    provisioner "local-exec" {
#      command = "ansible-playbook -u ubuntu -i ../ansible/inventory.yaml ansible-nginx-uwsgi/nginx-uwsgi.yml"
#    }
#    depends_on = [
#      null_resource.ansible_nginx_uwsgi
#    ]
#  }