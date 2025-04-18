terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.13.0"
    }
  }
}

provider "google" {
  //credentials = file(var.credentials) # Use this if you do not want to set env-var GOOGLE_APPLICATION_CREDENTIALS
  project     = var.project
  region      = var.region
}

resource "google_storage_bucket" "fashion_sales_storage_bucket" {
  name          = var.gcs_bucket_name
  location      = var.location
  // Ensure that all data inside the bucket is cleared when the bucket is deleted.
  force_destroy = true

  // If any object in the bucket has existed for more than 1 day and is an incomplete multipart upload,
  // Google Cloud will automatically abort these unfinished uploads to prevent wasting storage resources.
  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "fashion_sales_dataset" {
  dataset_id = var.bq_dataset_name
  location   = var.location
}