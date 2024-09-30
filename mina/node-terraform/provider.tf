terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.4.0"
    }
  }
}


provider "google" {
  project = "gcp-zero-to-hero-demos"
  region  = "us-central1"
  zone = "us-central1-a"
}