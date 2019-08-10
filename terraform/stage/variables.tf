variable zone {
  description = "Resource Terraform"
  default     = "europe-west1-b"
}

variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable privat_key_path {
  description = "Path to the privat key used for ssh access"
}

variable disk_image {
  description = "Disk image"
}

variable service_port {
  description = "Service_Port"
}

variable target_tags {
  description = "Teraget"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-base-app"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-ansible-db"
}
