#!/bin/bash

echo
echo "Tools"
echo
echo "    gcloud: $(gcloud --version | head -1)"
echo "    node  : $(node --version)"
echo "    jq    : $(jq --version)"
echo

echo
echo "User-Supplied Values"
echo
echo "    GOOGLE_REGION                 : $GOOGLE_REGION"
echo "    GOOGLE_APPLICATION_CREDENTIALS: $GOOGLE_APPLICATION_CREDENTIALS"
echo

echo
echo "Locally Inferred Values"
echo
echo "    gac_project_id                : $(gac_project_id)"
echo "    gac_client_email              : $(gac_client_email)"
echo "    gac_private_key_id            : $(gac_private_key_id)"
echo

echo
echo "Remotely Inferred Values"
echo
echo "    gcp_project_id                : $(gcp_project_id)"
echo "    gcp_project_number            : $(gcp_project_number)"
echo "    gcp_service_account_email     : $(gcp_service_account_email)"
echo "    gcp_service_account_key_name  : $(gcp_service_account_key_name)"
echo "    gcp_service_account_roles     : $(gcp_service_account_roles | tr '\n' ' ')"
echo
echo "    gcp_service_names:"
echo "$(gcp_service_names | sed -r -e 's/^/        /')"
echo

test "$(gcp_project_id)"                    == "$(gac_project_id)"             || echo "gcp_project_id                    <> gac_project_id"
test "$(gcp_service_account_email)"         == "$(gac_client_email)"           || echo "gcp_service_account_email         <> gac_client_email"
test "$(gcp_service_account_key_name)"      == "$(gac_private_key_id)"         || echo "gcp_service_account_key_name      <> gac_private_key_id"
test "$(gcp_service_name_cloud_build)"      == "cloudbuild.googleapis.com"     || echo "gcp_service_name_cloud_build      <> cloudbuild.googleapis.com"
test "$(gcp_service_name_cloud_functions)"  == "cloudfunctions.googleapis.com" || echo "gcp_service_name_cloud_functions  <> cloudfunctions.googleapis.com"
test "$(gcp_service_name_secret_manager)"   == "secretmanager.googleapis.com"  || echo "gcp_service_name_secret_manager   <> secretmanager.googleapis.com"
