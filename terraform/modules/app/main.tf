resource "google_compute_instance" "app" {
  name         = "${var.app_name_instance}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  boot_disk {
    initialize_params {
      image    = "${var.app_disk_image}"
    }
  }

  network_interface {
    network    = "default"

    access_config = {
      nat_ip   = "${google_compute_address.app_ip.address}"
    }
  }

  metadata {
    ssh-keys   = "appuser:${file(var.public_key_path)}"
  }

#  provisioner "file" {
#    source = "/home/adv/Otus/Lab2/ArtemAdm_infra/terraform/modules/app/puma.service"
#    destination = "/tmp/puma.service"
#  }

#  provisioner "remote-exec" {
#    script     = "/home/adv/Otus/Lab2/ArtemAdm_infra/terraform/modules/app/deploy.sh"
#  }

}

resource "google_compute_address" "app_ip" {
  name = "${var.name-ip}-app-ip"
}
