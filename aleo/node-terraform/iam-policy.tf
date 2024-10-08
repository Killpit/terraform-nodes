# Create the service account for the validator server
resource "google_service_account" "default" {
  account_id   = "aleo-prover-sa"
  display_name = "Aleo Prover Service Account"
}

# Create the GCS bucket for backups
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

# Create folders for different types of backup data
resource "google_storage_bucket_object" "validator_keys" {
  name   = "validator_keys/"  # Folder for validator keys
  bucket = google_storage_bucket.validator_backup.name
}

resource "google_storage_bucket_object" "config_files" {
  name   = "configuration_files/"  # Folder for configuration files
  bucket = google_storage_bucket.validator_backup.name
}

resource "google_storage_bucket_object" "blockchain_data" {
  name   = "blockchain_data/"  # Folder for blockchain data
  bucket = google_storage_bucket.validator_backup.name
}

resource "google_storage_bucket_object" "wallet_data" {
  name   = "wallet_data/"  # Folder for wallet data
  bucket = google_storage_bucket.validator_backup.name
}

resource "google_storage_bucket_object" "recovery_info" {
  name   = "recovery_information/"  # Folder for recovery information
  bucket = google_storage_bucket.validator_backup.name
}

# Define GCE instance with service account for validator server
resource "google_compute_instance" "confidential_instance" {
  name             = "aleo-prover"
  zone             = "us-central1-a"
  machine_type     = "n2-standard-8"
  min_cpu_platform = "Intel Cascade Lake"

  confidential_instance_config {
    enable_confidential_compute = true
    confidential_instance_type  = "SEV"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      labels = {
        my_label = "prover"
      }
    }
  }

  # Local SSD disk
  scratch_disk {
    interface = "NVME"
    size      = 80
  }

  network_interface {
    network = "default"
  }

  service_account {
    # Attach the custom service account
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

# IAM policy to grant GCS bucket access to the service account
resource "google_storage_bucket_iam_member" "validator_gcs_permissions" {
  bucket = google_storage_bucket.validator_backup.name
  role   = "roles/storage.objectAdmin"  # Full control over bucket objects
  member = "serviceAccount:${google_service_account.default.email}"
}

# (Optional) Grant read-only access to GCS bucket objects
resource "google_storage_bucket_iam_member" "validator_gcs_viewer" {
  bucket = google_storage_bucket.validator_backup.name
  role   = "roles/storage.objectViewer"  # Read-only access to bucket objects
  member = "serviceAccount:${google_service_account.default.email}"
}

# Assign Compute Instance Admin role to the service account
resource "google_project_iam_member" "validator_compute_instance_admin" {
  project = "your-project-id"
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.default.email}"
}

# Assign Service Account User role to allow GCE instance to use the service account
resource "google_project_iam_member" "validator_service_account_user" {
  project = "your-project-id"
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.default.email}"
}
