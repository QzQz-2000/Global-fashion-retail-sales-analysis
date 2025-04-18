variable "project" {
  description = "Project"
  default     = "fashion-retail-sales-project"
}

variable "credentials" {
  description = "My Credentials"
  default     = "./keys/credential.json"
}

variable "region" {
  description = "Region"
  default     = "europe-west4-a"
}

variable "location" {
  description = "Project Location"
  default     = "EU"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default     = "fashion_sales_dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  default     = "fashion_sales_storage_bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}