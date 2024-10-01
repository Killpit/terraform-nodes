resource "google_service_account" "default" {
  account_id   = "614303680090-compute@developer.gserviceaccount.com"
  display_name = "Aleo Prover"
}

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

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
    size = 80
  }

  network_interface {
    network = "default"
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}