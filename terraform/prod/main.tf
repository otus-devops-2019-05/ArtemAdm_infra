terraform {
  required_version = "> 0.11.6"
}

provider "google" {
  version = "2.0.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "app" {
  source            = "../modules/app"
  name-ip           = "prod"
  app_name_instance = "prod-reddit-app"
  public_key_path   = "${var.public_key_path}"
  zone              = "${var.zone}"
  app_disk_image    = "${var.app_disk_image}"
}

module "db" {
  source           = "../modules/db"
  db_name_instance = "prod-reddit-db"
  public_key_path  = "${var.public_key_path}"
  zone             = "${var.zone}"
  db_disk_image    = "${var.db_disk_image}"
}

module "vpc" {
  source            = "../modules/vpc"
  name-frw          = "prod"
  source_ranges     = ["77.52.206.86/32"]
}
