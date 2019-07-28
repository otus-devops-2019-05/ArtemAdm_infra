resource "google_compute_instance" "db" {
  name         = "${var.db_name_instance}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-db"]

  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  network_interface {
   network       = "default"
    access_config = {}
#     network_ip = "${google_compute_address.db_ip.address}"
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

#resource "google_compute_address" "db_ip" {
#  name = "db-ip"
#}

#resource "google_compute_network" "subnet" {
#  name = "my-net"
#}

#resource "google_compute_subnetwork" "subnet" {
#  name          = "my-subnet"
#  ip_cidr_range = "172.16.12.0/24"
#  region        = "europe-west2"
#  network       = "${google_compute_network.subnet.self_link}"
#}

#resource "google_compute_address" "internal_with_subnet_and_address" {
#  name         = "my-internal-address"
#  subnetwork   = "${google_compute_subnetwork.subnet.self_link}"
#  address_type = "INTERNAL"
#  address      = "172.16.12.11"
#  region       = "europe-west2"
#}
