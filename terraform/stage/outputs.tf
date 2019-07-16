#output "app_external_ip" {
#  value = "${google_compute_instance.app.network_interface.0.access_config.0.nat_ip}"
#}
output "app_external_ip" {
  value = "${module.app.app_external_ip}"
}
#output "db_network_ip" {
#  value = "${module.db.db_internal_ip}"
#}

