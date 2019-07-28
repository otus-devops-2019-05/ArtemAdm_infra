
variable zone {
  description = "Resource Terraform"
  default     = "europe-west1-b"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-base-db"
}

variable db_name_instance {
  description = "Name Instance DB"
  default     = "reddit-db"
}

#variable name-ip {
#  description = "privat ip"
#}

