variable zone {
  description = "Resource Terraform"
  default     = "europe-west1-b"
}

variable name {
  description = "Name"
}

variable "enable_http" {
  description = "Set to true to enable plain http. Note that disabling http does not force SSL and/or redirect HTTP traffic. See https://issuetracker.google.com/issues/35904733"
  default     = true
}

variable project {
  description = "Project ID"
}

variable region {
  description = "Region"

  # Значение по умолчанию
  default = "europe-west1"
}

variable app1_public_key_path {
  description = "Path to the public key used for ssh accessfor User appuser1"
}

variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}

variable privat_key_path {
  description = "Path to the privat key used for ssh access"
}

variable disk_image {
  description = "Disk image"
}

variable web_publickey {
  description = "web_ssh_key"
}

variable "custom_labels" {
  description = "A map of custom labels to apply to the resources. The key is the label name and the value is the label value."

  #  type        = map(string)
  default = {}
}

variable service_port {
  description = "Service_Port"
}

variable target_tags {
  description = "Teraget"
}

#variable "url_map" {
#  description = "A reference (self_link) to the url_map resource to use."
  #  type        = string
#}
