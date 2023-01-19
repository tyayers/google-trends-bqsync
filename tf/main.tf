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

resource "google_app_engine_application" "app" {
  project     = var.project_id
  location_id = var.data_region
  database_type = "CLOUD_FIRESTORE"
}

resource "google_service_account" "service_account" {
  project     = var.project_id
  account_id   = "trendservice2"
  display_name = "Trend Service Account2"
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

output "service_url" {
  value = google_cloud_run_service.trends_admin_service.status[0].url
}