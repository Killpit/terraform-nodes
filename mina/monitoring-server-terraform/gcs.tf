resource "google_storage_bucket" "static" {
 name          = "mina-monitoring"
 location      = "US"
 storage_class = "STANDARD"

 uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "prometheus_snapshot" {
  name         = "prometheus-snapshot.tar.gz"
  source       = "/path/to/snapshot.tar.gz"
  content_type = "application/gzip"
  bucket       = "mina-monioring"
}

resource "google_storage_bucket_object" "grafana_dashboard" {
  name         = "grafana-dashboard.json"
  source       = "/path/to/dashboard.json"
  content_type = "application/json"
  bucket       = "mina-monitoring"
}
