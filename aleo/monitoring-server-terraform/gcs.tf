provider "google" {
  project = "<YOUR_PROJECT_ID>"
  region  = "us-central1"
}
resource "google_storage_bucket" "elk_backup" {
  name          = "elk-backups-bucket"
  location      = "US"
  force_destroy = true
}

resource "google_storage_bucket_object" "logstash_logs" {
  name     = "logstash_logs/latest_logstash_logs.tar.gz"
  source   = "/path/to/local/logstash/logs/latest_logstash_logs.tar.gz" # Path on your local machine where logs are stored
  bucket   = google_storage_bucket.elk_backup.name
  content_type = "application/gzip"
}

resource "google_storage_bucket_object" "es_snapshots" {
  name     = "es_snapshots/latest_es_snapshot.tar.gz"
  source   = "/path/to/local/elasticsearch/snapshots/latest_es_snapshot.tar.gz" # Path on your local machine where snapshots are stored
  bucket   = google_storage_bucket.elk_backup.name
  content_type = "application/gzip"
}

resource "google_storage_bucket_object" "kibana_dashboards" {
  name     = "kibana_dashboards/latest_kibana_dashboards.json"
  source   = "/path/to/local/kibana/dashboards/latest_kibana_dashboards.json" # Path on your local machine where dashboards are exported
  bucket   = google_storage_bucket.elk_backup.name
  content_type = "application/json"
}

output "bucket_url" {
  value = google_storage_bucket.elk_backup.url
}
