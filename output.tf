output "external_ip_address_balance_nginx1" {
  value = "${yandex_compute_instance.balance_nginx1.network_interface.0.nat_ip_address}"
}
output "external_ip_address_balance_nginx2" {
  value = "${yandex_compute_instance.balance_nginx2.network_interface.0.nat_ip_address}"
}
output "internal_ip_address_balance_nginx1" {
  value = "${yandex_compute_instance.balance_nginx1.network_interface.0.ip_address}"
}
output "internal_ip_address_balance_nginx2" {
  value = "${yandex_compute_instance.balance_nginx2.network_interface.0.ip_address}"
}
output "internal_ip_address_backend1_nginx" {
  value = "${yandex_compute_instance.backend_nginx1.network_interface.0.ip_address}"
}
output "internal_ip_address_backend2_nginx" {
  value = "${yandex_compute_instance.backend_nginx2.network_interface.0.ip_address}"
}
output "internal_ip_address_backend3_nginx" {
  value = "${yandex_compute_instance.backend_nginx3.network_interface.0.ip_address}"
}
output "internal_ip_address_iscsi" {
  value = "${yandex_compute_instance.iscsi_target.network_interface.0.ip_address}"
}
output "internal_ip_address_db" {
  value = "${yandex_compute_instance.db.network_interface.0.ip_address}"
}
output "lb_ip_address" {
  value = "${[for s in yandex_lb_network_load_balancer.nlb.listener: s.external_address_spec.*.address].0[0]}"
}