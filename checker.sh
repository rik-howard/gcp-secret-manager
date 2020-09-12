#!/bin/bash

cattif () { cattee=$1; test -n "$cattee" && test -f "$cattee" && cat $cattee; }

gac_project_id     () { cattif $GOOGLE_APPLICATION_CREDENTIALS | jq -r '.project_id'; }
gac_client_email   () { cattif $GOOGLE_APPLICATION_CREDENTIALS | jq -r '.client_email'; }
gac_private_key_id () { cattif $GOOGLE_APPLICATION_CREDENTIALS | jq -r '.private_key_id'; }
gac_email_suffix   () { echo $(gac_project_id).iam.gserviceaccount.com; }

gcp_project_id () {
    gcloud projects list\
    --filter=PROJECT_ID:$(gac_project_id)\
    --format='value(PROJECT_ID)' 2>/dev/null
}

gcp_project_number () {
    gcloud projects list\
    --filter=PROJECT_ID:$(gac_project_id)\
    --format='value(PROJECT_NUMBER)' 2>/dev/null
}

gcp_service_account_email () {
    gcloud iam service-accounts list\
    --filter=EMAIL:$(gac_client_email)\
    --format='value(EMAIL)' 2>/dev/null
}

gcp_service_account_key_name () {
    gcloud iam service-accounts keys list\
    --filter=keyType:USER_MANAGED\
    --format='value(KEY_ID)'\
    --iam-account=$(gac_client_email) 2>/dev/null
}

gcp_service_account_roles () {
    gcloud projects get-iam-policy $(gac_project_id)\
    --format=json 2>/dev/null |
    jq -r '
        .bindings |
        map (select (.members[] |
        contains ("serviceAccount:'$(gac_client_email)'"))) |
        .[] .role
    '
}

gcp_service_names () {
    gcloud services list\
    --format='value(NAME)' 2>/dev/null
}

gcp_service_name_cloud_build () {
    gcloud services list\
    --filter=NAME:cloudbuild\
    --format='value(NAME)' 2>/dev/null
}

gcp_service_name_cloud_functions () {
    gcloud services list\
    --filter=NAME:cloudfunctions\
    --format='value(NAME)' 2>/dev/null
}

gcp_service_name_secret_manager () {
    gcloud services list\
    --filter=NAME:secretmanager\
    --format='value(NAME)' 2>/dev/null
}

export -f cattif
export -f gac_project_id
export -f gac_client_email
export -f gac_private_key_id
export -f gcp_project_id
export -f gcp_project_number
export -f gcp_service_account_email
export -f gcp_service_account_key_name
export -f gcp_service_account_roles
export -f gcp_service_names
export -f gcp_service_name_cloud_build
export -f gcp_service_name_cloud_functions
export -f gcp_service_name_secret_manager
