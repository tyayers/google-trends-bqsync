# Variables

variable "project_id" {
  description = "Project id to deploy the application to."
  type        = string
}

variable "billing_account" {
  description = "Billing account id."
  type        = string
  default     = null
}

variable "project_parent" {
  description = "Parent folder or organization in 'folders/folder_id' or 'organizations/org_id' format."
  type        = string
  default     = null
  validation {
    condition     = var.project_parent == null || can(regex("(organizations|folders)/[0-9]+", var.project_parent))
    error_message = "Parent must be of the form folders/folder_id or organizations/organization_id."
  }
}

variable "project_create" {
  description = "Create project. When set to false, uses a data source to reference existing project."
  type        = bool
  default     = false
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

module "project" {
  source          = "github.com/terraform-google-modules/cloud-foundation-fabric//modules/project?ref=v15.0.0"
  name            = var.project_id
  parent          = var.project_parent
  billing_account = var.billing_account
  project_create  = var.project_create
  services = [
    "compute.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudscheduler.googleapis.com",
    "run.googleapis.com",
    "bigquery.googleapis.com"
  ]
  policy_boolean = {
    "constraints/compute.requireOsLogin" = false
    "constraints/compute.requireShieldedVm" = false
  }
  policy_list = {
    "constraints/iam.allowedPolicyMemberDomains" = {
        inherit_from_parent: false
        status: true
        suggested_value: null
        values: [],
        allow: {
          all=true
        }
    },
    "constraints/compute.vmExternalIpAccess" = {
        inherit_from_parent: false
        status: true
        suggested_value: null
        values: [],
        allow: {
          all=true
        }
    }
  }
}

resource "google_project_service" "enable_artifactregistry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"

  depends_on = [module.project]
}

resource "google_project_service" "enable_cloudbuild" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"

  depends_on = [module.project] 
}

resource "google_project_service" "enable_scheduler" {
  project = var.project_id
  service = "cloudscheduler.googleapis.com"

  depends_on = [module.project]
}

resource "google_project_service" "enable_cloudrun" {
  project = var.project_id
  service = "run.googleapis.com"

  depends_on = [module.project]
}

resource "google_project_service" "enable_bigquery" {
  project = var.project_id
  service = "bigquery.googleapis.com"
  disable_dependent_services = true

  depends_on = [module.project]
}

resource "google_project_service" "enable_firestore" {
  project = var.project_id
  service = "firestore.googleapis.com"
  disable_dependent_services = true

  depends_on = [module.project]
}

resource "google_app_engine_application" "app" {
  project     = var.project_id
  location_id = var.data_region
  database_type = "CLOUD_FIRESTORE"

  depends_on = [google_project_service.enable_firestore]
}

resource "google_service_account" "service_account" {
  project     = var.project_id
  account_id   = "trendservice"
  display_name = "Trend Service Account"

  depends_on = [module.project]
}

resource "google_project_iam_member" "firestore_owner_binding" {
  project = var.project_id
  role    = "roles/datastore.owner"
  member  = "serviceAccount:${google_service_account.service_account.email}"

  depends_on = [module.project]
}

resource "google_project_iam_member" "run_invoker_binding" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.service_account.email}"

  depends_on = [module.project]
}

resource "google_project_iam_member" "bigquery_editor_binding" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.service_account.email}"

  depends_on = [module.project]
}

resource "google_artifact_registry_repository" "trends-registry" {
  project = var.project_id
  location      = var.region
  repository_id = "trends-registry"
  description   = "Registry for trends artifacts"
  format        = "DOCKER"
  
  provisioner "local-exec" {
    command = "cd .. && gcloud builds submit --project=${var.project_id} --config=cloudbuild.yaml --substitutions=_LOCATION='${var.region}',_REPOSITORY='trends-registry',_IMAGE='trends-service' ."
  }

  depends_on = [google_project_service.enable_artifactregistry]
}

resource "google_cloud_run_service" "trends_admin_service" {
  name     = "trends-admin-service"
  project = var.project_id
  location = var.region

  template {
    spec {
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/trends-registry/trends-service"
        env {
          name = "GCLOUD_PROJECT"
          value = var.project_id
        }      
      }   
      service_account_name = google_service_account.service_account.email
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_artifact_registry_repository.trends-registry]
}

# resource "google_cloud_run_service_iam_member" "run_all_users" {
#   service  = google_cloud_run_service.trends_admin_service.name
#   location = google_cloud_run_service.trends_admin_service.location
#   role     = "roles/run.invoker"
#   member   = "serviceAccount:${google_service_account.service_account.email}"
# }

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.trends_admin_service.location
  project     = google_cloud_run_service.trends_admin_service.project
  service     = google_cloud_run_service.trends_admin_service.name

  policy_data = data.google_iam_policy.noauth.policy_data
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
    http_method = "POST"
    uri         = "${google_cloud_run_service.trends_admin_service.status[0].url}/trends/cold/refresh"

    oidc_token {
      service_account_email = google_service_account.service_account.email
      audience = google_cloud_run_service.trends_admin_service.status[0].url
    }
  }

  provisioner "local-exec" {
    command = "curl -X POST ${google_cloud_run_service.trends_admin_service.status[0].url}/trends/cold/initial"
  }

  depends_on = [google_cloud_run_service.trends_admin_service]
}

resource "google_firestore_document" "trends" {
  project     = var.project_id
  collection  = "trends"
  document_id = "cold"
  #fields      = "{\"geos\": {\"arrayValue\": {\"values\": [{\"stringValue\": \"WORLD\"}, {\"stringValue\": \"US\"}, {\"stringValue\": \"GB\"}, {\"stringValue\": \"DE\"}]}}, \"terms\": {\"arrayValue\": {\"values\": [{\"mapValue\": {\"fields\": {\"name\": {\"stringValue\": \"rhinovirus\"}}}}]}}}"
  fields      = jsonencode(jsondecode(file("${path.module}/fs_data_fs.json")))
  depends_on  = [google_app_engine_application.app]
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

  depends_on = [google_project_service.enable_bigquery]
}

resource "google_bigquery_table" "default" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = "trends"
  deletion_protection=false

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
    "name": "topic",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "The topic of the search trend value."
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

  depends_on = [google_bigquery_dataset.default]
}

# Outputs

# output "service_url" {
#   value = google_cloud_run_service.trends_admin_service.status[0].url
# }
