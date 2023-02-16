cd tf

terraform init
terraform apply -var "project_id=PROJECT_ID" -var "data_region=europe-west" -var "region=europe-west1"

cd ..