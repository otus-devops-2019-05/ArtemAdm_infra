terraform {
  # Версия terraform
  required_version = "0.11.7"
}

#provider "google-beta" {
#  project = "${var.project}"
#  region  = "${var.region}"
#}

#resource "google_compute_global_address" "default" {
#  project      = "${var.project}"
#  name         = "${var.name}-address"
#  ip_version   = "IPV4"
#  address_type = "EXTERNAL"
#}

###########URL
#resource "google_compute_url_map" "urlmap" {
#  project = "${var.project}"
#
#  name        = "${var.name}-url-map"
#  description = "URL map for ${var.name}"

#  default_service = "google_compute_backend_bucket.static.self_link"

# host_rule {
#    hosts        = ["*"]
#    path_matcher = "all"
#  }

#  path_matcher {
#    name            = "all"
#    default_service = "google_compute_backend_bucket.static.self_link"

#    path_rule {
#      paths   = ["/api", "/api/*"]
#      service = "google_compute_backend_service.api.self_link"
#    }
#  }
#}

# ------------------------------------------------------------------------------
# IF PLAIN HTTP ENABLED, CREATE FORWARDING RULE AND PROXY
# ------------------------------------------------------------------------------

#resource "google_compute_target_http_proxy" "http" {
#  count   = "${var.enable_http ? 1 : 0}"
#  project = "${var.project}"
#  name    = "${var.name}-http-proxy"
#  url_map = "${var.url_map}"
#}

#resource "google_compute_global_forwarding_rule" "http" {
#  provider   = "google-beta"
#  count      = "${var.enable_http ? 1 : 0}"
#  project    = "${var.project}"
#  name       = "${var.name}-http-rule"
#  target     = "google_compute_target_http_proxy.http[0].self_link"
#  ip_address = "google_compute_global_address.default.address"
#  port_range = "${var.service_port}"
#  alias      = "gbeta-us-west1"
#  labels     = "${var.custom_labels}"
#}

#resource "google_compute_firewall" "default-lb-fw" {
#  project = "${var.project}"
#  name    = "${var.name}-vm-service"
#  network = "default"

#  allow {
#    protocol = "tcp"
#    ports    = ["${var.service_port}"]
#  }

#  source_ranges = ["0.0.0.0/0"]
#  target_tags   = ["${var.target_tags}"]
#}

# ------------------------------------------------- -----------------------------
# СОЗДАЙТЕ ГРУППУ INSTANCE С ОДНОЙ ИНСТАНЦИЕЙ И КОНФИГУРАЦИЕЙ ОБСЛУЖИВАНИЯ BACKEND
#
# Мы используем группу экземпляров только для того, чтобы выделить возможность указать несколько типов
# бэкэндов для балансировщика нагрузки
# ------------------------------------------------- -----------------------------

resource "google_compute_instance_group" "api" {
  project = "${var.project}"
  name    = "${var.name}-instance-group"
  zone    = "${var.zone}"

  instances = [
    "${google_compute_instance.api.self_link}",
  ]

  lifecycle {
    create_before_destroy = true
  }

  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_instance" "api" {
  project      = "${var.project}"
  name         = "${var.name}-instance"
  machine_type = "f1-micro"
  zone         = "${var.zone}"

  ### Мы помечаем экземпляр тегом, указанным в правиле брандмауэра
  tags = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  ### Убедитесь, что у нас запущено колба
  metadata {
    # путь до публичного ключа
    ssh-keys = "appuser:${file(var.public_key_path)} \nappuser1:${file(var.app1_public_key_path)}"
  }

  connection {
    type  = "ssh"
    user  = "appuser"
    agent = false

    # путь до приватного ключа
    private_key = "${file(var.privat_key_path)}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }

  # Запустить экземпляр в подсети по умолчанию
  network_interface {
    subnetwork = "default"

    # Это дает экземпляру публичный IP-адрес для подключения к интернету. Обычно у вас будет Cloud NAT,
    # но ради простоты мы назначаем публичный IP для подключения к интернету
    # чтобы иметь возможность запускать сценарии запуска
    access_config {}
  }
}

resource "google_compute_backend_service" "api" {
  name      = "staging-service"
  port_name = "http"
  protocol  = "HTTP"

  backend {
    group = "${google_compute_instance_group.api.self_link}"
  }

  health_checks = [
    "${google_compute_http_health_check.staging_health.self_link}",
  ]

  #  depends_on = [
  #    "${google_compute_instance_group.api}"
  #  ]
}

resource "google_compute_http_health_check" "staging_health" {
  name = "${var.name}-hc"

  #  request_path = "/health_check"
  #http_health_check {
  port = 80

  request_path = "/api"

  #}

  check_interval_sec = 5
  timeout_sec        = 5

  #  healthy_threshold   = 2
  #  unhealthy_threshold = 3
}
