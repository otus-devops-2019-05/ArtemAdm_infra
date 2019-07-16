terraform {
  required_version = "> 0.11.6"
}

provider "google" {
  version = "2.0.0"
  project = "${var.project}"
  region  = "europe-west2"
}

module "app" {
  source            = "../modules/app"
  zone              = "europe-west2-b"
  app_name_instance = "stage-reddit-app"
  name-ip           = "stage"
  public_key_path   = "${var.public_key_path}"
#  zone              = "${var.zone}"
  app_disk_image    = "${var.app_disk_image}"
}

module "db" {
  source           = "../modules/db"
  zone             = "europe-west2-b"
  db_name_instance = "stage-reddit-db"
  public_key_path  = "${var.public_key_path}"
#  zone             = "${var.zone}"
  name-ip          = "stage"
  db_disk_image    = "${var.db_disk_image}"
}

module "vpc" {
  source        = "../modules/vpc"
  name-frw      = "stage"
  source_ranges = ["0.0.0.0/0"]
}
