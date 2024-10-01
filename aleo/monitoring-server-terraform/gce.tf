provider "google" {
  project = "<YOUR_PROJECT_ID>"    # Replace with your GCP project ID
  region  = "us-central1"          # Choose your preferred region
}

resource "google_compute_instance" "elk" {
  name         = "elk-instance"
  machine_type = "e2-medium"       
  zone         = "us-central1-a"   

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12" 
      labels = {
        my_label = "prover"
      }
    }
  }

  scratch_disk {
    interface = "NVME"
    size = 30
  }

  network_interface {
    network       = "default"         
  }

  metadata_startup_script = <<-EOF
              #!/bin/bash
              # Update the package index
              sudo apt-get update -y
              
              # Install Java (required for Elasticsearch)
              sudo apt-get install -y openjdk-21-jdk
              
              # Install Elasticsearch
              wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
              echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
              sudo apt-get update -y
              sudo apt-get install -y elasticsearch
              sudo systemctl start elasticsearch
              sudo systemctl enable elasticsearch

              # Install Logstash
              sudo apt-get install -y logstash
              sudo systemctl start logstash
              sudo systemctl enable logstash

              # Install Kibana
              sudo apt-get install -y kibana
              sudo systemctl start kibana
              sudo systemctl enable kibana

              # Install Metricbeat
              sudo apt-get install -y metricbeat
              sudo systemctl start metricbeat
              sudo systemctl enable metricbeat
              EOF

  tags = ["elk"]
}

resource "google_compute_firewall" "elk_firewall" {
  name    = "elk-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9200", "5601", "5044"]  
  }

  source_ranges = ["0.0.0.0/0"]  
}

output "elk_instance_ip" {
  value = google_compute_instance.elk.network_interface[0].access_config[0].nat_ip
}