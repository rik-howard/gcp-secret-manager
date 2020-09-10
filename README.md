


# GCP Secret Manager
This project experiments with GCP Secret Manager.

> ≡ Security: Secret Manager


## Tearing down
From the folder containing this read-me, execute tne following.

    gcloud_tear_down    # to delete everything except the project or
    gcloud_tear_down @  # to delete everything
    clear; show_path; show_google; show_foundation


## Setting up
From the folder containing this read-me, execute tne following.

    source path gcloud
    source gcloud-configurer "$(basename $(pwd))-"
    source gcloud-builder
    clear; show_path; show_google; show_foundation
    gcloud_set_up cloudresourcemanager serviceusage


## Enabling the API

    gcloud services enable secretmanager.googleapis.com --project=$GOOGLE_PROJECT


## Creating some secrets

    echo -n "first secret, first version" |
    gcloud secrets create first-secret\
        --replication-policy=automatic\
        --data-file=-

    echo -n "second secret, first version" |
    gcloud secrets create second-secret\
        --replication-policy=user-managed\
        --locations=europe-west1\
        --data-file=-


## Accessing the secrets

    gcloud secrets versions access 1 --secret=first-secret
    gcloud secrets versions access latest --secret=second-secret


## Incrementing the secrets

    echo -n "first secret, second version" |
    gcloud secrets versions add first-secret\
        --data-file=-

    echo -n "second secret, second version" |
    gcloud secrets versions add second-secret\
        --data-file=-

Access them again.


## Node
See *quick-start.js*.

    source path gcloud node jq
    npm init
    npm install --save @google-cloud/secret-manager  # puts in this folder 🤮
    export GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_CREDENTIALS

    node quick-start.js

    gcloud projects add-iam-policy-binding $GOOGLE_PROJECT\
        --member=serviceAccount:$(gcloud_project_service_account_email)\
        --role=roles/secretmanager.admin

    gcloud secrets delete third-secret --quiet


## Cloud Function
See *index.js*.  Probably best to create *.gcloudignore* now.

    cat package.json | jq '.main = "index.js"' > tmp/package.json && mv tmp/package.json package.json
    source gcloud-configurer $GOOGLE_PROJECT $GOOGLE_CREDENTIALS europe-west1
    clear; show_path; show_google; show_foundation
    gcloud services enable cloudbuild.googleapis.com --project=$GOOGLE_PROJECT  # note containerregistry
    gcloud services enable cloudfunctions.googleapis.com --project=$GOOGLE_PROJECT

    gcloud functions deploy secret-accessor\
        --set-env-vars=PROJECT_NUMBER=$(gcloud_project_number)\
        --entry-point=secretAccessor\
        --region=$GOOGLE_REGION\
        --allow-unauthenticated\
        --runtime=nodejs10\
        --trigger-http

    export DATA='{"secretName": "first-secret", "secretVersion": 1}'

    gcloud functions call secret-accessor --data="$DATA" --region=$GOOGLE_REGION

    gcloud projects add-iam-policy-binding $GOOGLE_PROJECT\
        --member=serviceAccount:$GOOGLE_PROJECT@appspot.gserviceaccount.com\
        --role=roles/secretmanager.secretAccessor

    gcloud projects get-iam-policy $GOOGLE_PROJECT --format=json > iam-policy.json

Intro into *iam-policy.json*

    "condition" : {
        "title": "second-secret-conditon",
        "description": "This should limit the SA to only accessing the second secret.",
        "expression": "resource.name.startsWith('projects/${PROJECT_NUMBER}/secrets/second-secret')"
    }

Then

    gcloud projects set-iam-policy $GOOGLE_PROJECT iam-policy.json

    gcloud functions call secret-accessor --data="$DATA" --region=$GOOGLE_REGION

    export DATA='{"secretName": "second-secret", "secretVersion": 1}'
    export DATA='{"secretName": "second-secret", "secretVersion": 2}'
    export DATA='{"secretName": "second-secret", "secretVersion": "latest"}'

    gcloud functions call secret-accessor --data="$DATA" --region=$GOOGLE_REGION

Visit

    export FUNCTION_HOST="${GOOGLE_REGION}-${GOOGLE_PROJECT}.cloudfunctions.net"
    export FUNCTION_NAME="secret-accessor"
    export FUNCTION_QUERY="secretName=second-secret&secretVersion=1"

    echo "https://${FUNCTION_HOST}/${FUNCTION_NAME}?${FUNCTION_QUERY}"

Note

    gcloud functions describe secret-accessor --region=$GOOGLE_REGION
