resource "google_storage_bucket" "validator_backup" {
  name     = "aleo-backup" # Replace with a unique bucket name
  location = "US"                       # Replace with your desired location

  versioning {
    enabled = true                      # Enable versioning for backups
  }

  lifecycle {
    prevent_destroy = true              # Prevent accidental deletion of the bucket
  }
}

# Create a folder for Validator Keys
resource "google_storage_bucket_object" "validator_keys" {
  name   = "validator_keys/"            # Folder for validator keys
  bucket = google_storage_bucket.validator_backup.name
}

# Create a folder for Configuration Files
resource "google_storage_bucket_object" "config_files" {
  name   = "configuration_files/"       # Folder for configuration files
  bucket = google_storage_bucket.validator_backup.name
}

# Create a folder for Blockchain Data
resource "google_storage_bucket_object" "blockchain_data" {
  name   = "blockchain_data/"           # Folder for blockchain data
  bucket = google_storage_bucket.validator_backup.name
}

# Create a folder for Wallet Data
resource "google_storage_bucket_object" "wallet_data" {
  name   = "wallet_data/"               # Folder for wallet data
  bucket = google_storage_bucket.validator_backup.name
}

# Create a folder for Recovery Information
resource "google_storage_bucket_object" "recovery_info" {
  name   = "recovery_information/"       # Folder for recovery information
  bucket = google_storage_bucket.validator_backup.name
}
