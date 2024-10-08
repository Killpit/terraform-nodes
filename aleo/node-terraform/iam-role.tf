provider "google" {
  project = "your-project-id"  # Replace with your Google Cloud project ID
  region  = "us-central1"       # Replace with your desired region
}

# Create a Service Account for the Validator Node
resource "google_service_account" "validator_node" {
  account_id   = "validator-node-sa"
  display_name = "Validator Node Service Account"
}

# Create the GCS Bucket for Validator Backups
resource "google_storage_bucket" "validator_backup" {
  name     = "aleo-backup" # Replace with a unique bucket name
  location = "US"          # Replace with your desired location

  versioning {
    enabled = true          # Enable versioning for backups
  }

  lifecycle {
    prevent_destroy = true  # Prevent accidental deletion of the bucket
  }
}

# Create folders in the GCS bucket for different data types
resource "google_storage_bucket_object" "validator_keys" {
  name   = "validator_keys/"            # Folder for validator keys
  bucket = google_storage_bucket.validator_backup.name
}

resource "google_storage_bucket_object" "config_files" {
  name   = "configuration_files/"       # Folder for configuration files
  bucket = google_storage_bucket.validator_backup.name
}

resource "google_storage_bucket_object" "blockchain_data" {
  name   = "blockchain_data/"           # Folder for blockchain data
  bucket = google_storage_bucket.validator_backup.name
}

resource "google_storage_bucket_object" "wallet_data" {
  name   = "wallet_data/"               # Folder for wallet data
  bucket = google_storage_bucket.validator_backup.name
}

resource "google_storage_bucket_object" "recovery_info" {
  name   = "recovery_information/"       # Folder for recovery information
  bucket = google_storage_bucket.validator_backup.name
}

# IAM Role: Storage Object Creator for GCS backups
resource "google_project_iam_member" "validator_storage_object_creator" {
  project = "your-project-id"
  role    = "roles/storage.objectCreator"
  member  = "serviceAccount:${google_service_account.validator_node.email}"
}

# IAM Role: Storage Object Viewer for GCS
resource "google_project_iam_member" "validator_storage_object_viewer" {
  project = "your-project-id"
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.validator_node.email}"
}

# IAM Role: Compute Instance Admin for managing the validator node
resource "google_project_iam_member" "validator_compute_instance_admin" {
  project = "your-project-id"
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.validator_node.email}"
}

# Create a Compute Engine instance for the Validator Node
resource "google_compute_instance" "validator_node_instance" {
  name             = "aleo-validator"
  zone             = "us-central1-a"  # Replace with your desired zone
  machine_type     = "n2-standard-8"
  min_cpu_platform = "Intel Cascade Lake"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"  # Replace with your preferred image
    }
  }

  network_interface {
    network = "default"
    access_config {
      # Assign a public IP address
    }
  }

  service_account {
    email  = google_service_account.validator_node.email
    scopes = ["cloud-platform"]  # Scope for accessing GCP services
  }
}
