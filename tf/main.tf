variable "project_id" {
  description = "Project id (also used for the Apigee Organization)."
  type        = string
}

variable "region" {
  description = "GCP region for storing firebase data (see https://cloud.google.com/apigee/docs/api-platform/get-started/install-cli)."
  type        = string
}

resource "google_app_engine_application" "app" {
  project     = var.project_id
  location_id = var.region
  database_type = "CLOUD_FIRESTORE"
}