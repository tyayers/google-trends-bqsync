# google-trends-bqsync

This is a small serverless project to manage the synchronization of google trends updates to BigQuery.

# Google Trends BQ Sync Template

This is a simple solution to setup automatic syncing of [Google Trends](https://trends.google.com) data into a BigQuery table. This includes a **Cloud Run** python function to fetch the trends data using the **pytrends** library, which then writes the data into BigQuery for analytics and trend tracking. Additionally there is a **Google Cloud Scheduler** job to sync the data automatically daily.

## Deployment

You can deploy the solution using **terraform** in **Google Cloud Shell**. If you want to create a new project for the deployment, then you can set the variable `project_create=true` and set the appropriate `billing_account`. If not you can just supply a `project_id` to deploy to.

```bash
cd tf

terraform apply -var "project_id=PROJECT_ID" -var "project_create=true" -var "billing_account=BILLING_ID"
```

You can also open a tutorial directly in **Google Cloud Shell**.

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/tyayers/google-trends-bqsync&cloudshell_git_branch=main&cloudshell_workspace=.&cloudshell_tutorial=docs/tutorial.md)
