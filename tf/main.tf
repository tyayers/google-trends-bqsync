# Variables

variable "project_id" {
  description = "Project id to deploy the application to."
  type        = string
}

variable "data_region" {
  description = "GCP data region to deploy to (see https://cloud.google.com/appengine/docs/standard/locations)."
  type        = string
}

variable "region" {
  description = "GCP region to deploy to (see https://cloud.google.com/appengine/docs/standard/locations)."
  type        = string
}

# Resources

resource "google_project_service" "enable_artifactregistry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "enable_scheduler" {
  project = var.project_id
  service = "cloudscheduler.googleapis.com"
}

resource "google_project_service" "enable_cloudrun" {
  project = var.project_id
  service = "run.googleapis.com"
}

resource "google_project_service" "enable_bigquery" {
  project = var.project_id
  service = "bigquery.googleapis.com"
}

resource "google_app_engine_application" "app" {
  project     = var.project_id
  location_id = var.data_region
  database_type = "CLOUD_FIRESTORE"
}

resource "google_service_account" "service_account" {
  project     = var.project_id
  account_id   = "trendservice"
  display_name = "Trend Service Account"
}

resource "google_project_iam_member" "firestore_owner_binding" {
  project = var.project_id
  role    = "roles/datastore.owner"
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_artifact_registry_repository" "trends-registry" {
  project = var.project_id
  location      = var.region
  repository_id = "trends-registry"
  description   = "Registry for trends artifacts"
  format        = "DOCKER"
  
  provisioner "local-exec" {
    command = "cd .. && gcloud builds submit --config=cloudbuild.yaml --substitutions=_LOCATION='${var.region}',_REPOSITORY='trends-registry',_IMAGE='trends-service' ."
  }
}

resource "google_cloud_run_service" "trends_admin_service" {
  name     = "trends-admin-service"
  project = var.project_id
  location = var.region

  template {
    spec {
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/trends-registry/trends-service"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.enable_cloudrun]
}

resource "google_cloud_scheduler_job" "trends-refresh" {
  name             = "trends-refresh"
  project          = var.project_id
  region = var.region
  description      = "Job to refresh the trends data."
  schedule         = "0 5 * * *"
  time_zone        = "Europe/Amsterdam"
  attempt_deadline = "320s"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "GET"
    uri         = google_cloud_run_service.trends_admin_service.status[0].url
  }

  depends_on = [google_cloud_run_service.trends_admin_service]
}

resource "google_bigquery_dataset" "default" {
  project                     = var.project_id
  dataset_id                  = "trends_dataset"
  friendly_name               = "trends-dataset"
  description                 = "This is a dataset for collecting trends data."
  location                    = "EU"

  labels = {
    env = "default"
  }
}

resource "google_bigquery_table" "default" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = "trends"

  time_partitioning {
    type = "DAY"
  }

  labels = {
    env = "default"
  }

  schema = <<EOF
[
  {
    "name": "geo",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The trends search term."
  },
  {
    "name": "name",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The geo of the search trend value."
  },  
  {
    "name": "date",
    "type": "DATE",
    "mode": "REQUIRED",
    "description": "The date of the trends search."
  },
  {
    "name": "score",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "The score of the term on the date."
  }
]
EOF

}

# Outputs

# output "service_url" {
#   value = google_cloud_run_service.trends_admin_service.status[0].url
# }
