variable "project_id" {
  description = "Project id to deploy the application to."
  type        = string
}

variable "region" {
  description = "GCP region to deploy to (see https://cloud.google.com/appengine/docs/standard/locations)."
  type        = string
}

resource "google_app_engine_application" "app" {
  project     = var.project_id
  location_id = var.region
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