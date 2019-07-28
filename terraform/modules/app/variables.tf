variable zone {
  description = "Resource Terraform"
  default     = "europe-west1-b"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-base-app"
}

variable app_name_instance {
  description = "Name Instance"
  default     = "reddit-app"
}

variable name-ip {
  description = "Name Firewall puma"
}

