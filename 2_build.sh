gcloud builds submit --config=cloudbuild.yaml \
  --substitutions=_LOCATION="europe-west1",_REPOSITORY="trends-registry",_IMAGE="trends-service" .