# Configure the GCP provider
provider "google" {
  project     = "akiva-sandbox"
  region      = "us-central1" 
}

resource "google_compute_instance" "phase1-instance" {
  name         = "phase1-instance"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  tags = ["http-server"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata_startup_script = file("startup-script.sh")
}

resource "google_sql_database_instance" "instance" {
  provider = google-beta
  project = "akiva-sandbox"
  name             = "phase1-db"
  region           = "us-central1"
  database_version = "POSTGRES_13"

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled                                  = true
    }
  }
}

#Create a Cloud SQL database (PostgreSQL)
resource "google_sql_database" "app_database" {
  name     = "app-database"
  instance = google_sql_database_instance.instance.name
}

# Create a Cloud SQL user (PostgreSQL)
resource "google_sql_user" "app_db_user" {
  name     = "app-db-user"
  instance = google_sql_database_instance.instance.name
  password = "pass"  # Change to a secure password
}
