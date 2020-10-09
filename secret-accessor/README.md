


# GCP Secret Manager: Secret Accessor
See

* [index.js](index.js)
* [.gcloudignore](.gcloudignore)


## Enhance the Cloud Function System Service Account

    gcloud projects add-iam-policy-binding $(gac_project_id)\
        --member=serviceAccount:service-$(gcp_project_number)@gcf-admin-robot.iam.gserviceaccount.com\
        --role=roles/storage.objectCreator


## Create and Enrole a Secret-Accessing Service Account

    gcloud iam service-accounts create secret-accessor\
        --display-name=Secret_Accessor\
        --project=$(gac_project_id)

    gcloud projects add-iam-policy-binding $(gac_project_id)\
        --member=serviceAccount:secret-accessor@$(gac_email_suffix)\
        --role=roles/secretmanager.secretAccessor


## Install the Dependencies
Assuming that the commands are being run from the folder containing this read-me,

    npm install @google-cloud/secret-manager


## Deploy the Cloud Function

    gcloud functions deploy secret-accessor\
        --set-env-vars=PROJECT_NUMBER=$(gcp_project_number)\
        --service-account=secret-accessor@$(gac_email_suffix)\
        --entry-point=secretVersionAccession\
        --source=secret-accessor\
        --allow-unauthenticated\
        --region=$GOOGLE_REGION\
        --runtime=nodejs12\
        --trigger-http


## Exercise the Cloud Function
This uses GCloud to exercise with some posted name-value pairs.

    export DATA='{"secretName": "first-secret", "secretVersion": 1}'
    gcloud functions call secret-accessor --data="$DATA" --region=$GOOGLE_REGION

This is for a browser to exercise with some query name-value pairs.

    export GCF_HOST="${GOOGLE_REGION}-$(gac_project_id).cloudfunctions.net"
    export GCF_NAME="secret-accessor"
    export GCF_QUERY="secretName=second-secret&secretVersion=1"
    echo "https://$GCF_HOST/$GCF_NAME?$GCF_QUERY"


## Restrict the Secret-Accessing Service Account to a Single Secret
Get the IAM policy from GCP.

    gcloud projects get-iam-policy $(gac_project_id) --format=json > iam-policy.json

In *iam-policy.json*, update the binding for the secret accessor role with a condition.

    "condition" : {
        "title": "second-secret-conditon",
        "description": "This should limit the SA to only accessing the second secret.",
        "expression": "resource.name.startsWith('projects/$(gcp_project_number)/secrets/second-secret')"
    },

    sed -i -r -e "s/..gcp_project_number./$(gcp_project_number)/" iam-policy.json

Set the IAM policy to GCP.

    gcloud projects set-iam-policy $GOOGLE_PROJECT iam-policy.json


## Exercise the Cloud Function Again
This will fail now, although sometimes the condition may take a few minutes to propagate.

    export DATA='{"secretName": "first-secret", "secretVersion": 1}'
    gcloud functions call secret-accessor --data="$DATA" --region=$GOOGLE_REGION

These succeed.

    export DATA='{"secretName": "second-secret", "secretVersion": 1}'
    export DATA='{"secretName": "second-secret", "secretVersion": 2}'
    export DATA='{"secretName": "second-secret", "secretVersion": "latest"}'
    gcloud functions call secret-accessor --data="$DATA" --region=$GOOGLE_REGION
