terraform {
  backend "gcs" {
    bucket = "storage-bucket-adv2"
    prefix = "stage"
  }
}
