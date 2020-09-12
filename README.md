


# GCP Secret Manager
This project experiments with GCP Secret Manager.  Some secrets that are held by the manger are manipulated from a local command line and from a Cloud Function.  GCloud, Node and JQ are used to manage the APIs, IAMs, GCF and GSM.

* ≡: Top: APIs and Services: Dashboard
* ≡: Top: IAM and Admin: IAM
* ≡: Top: IAM and Admin: Service Accounts
* ≡: Top: Security: Secret Manager
* ≡: Tools: Cloud Build: Dashboard
* ≡: Compute: Cloud Functions


## Assumptions
There is a billing-enabled project, with a service account, in GCP.  The project has the Cloud Build, Cloud Functions and Secret Manager APIs enabled.  The $GOOGLE_APPLICATION_CREDENTIALS and $GOOGLE_REGION environment variables have been exported, respectively containing the (relative or absolute) path to the service account's JSON key file and a desired region.  Logged in as an owner, execute

    source checker.sh; check.sh

It should look something like this (where gac abbreviates Google application credentials):

    Tools

        gcloud: Google Cloud SDK 309.0.0
        node  : v12.16.3
        jq    : jq-1.6

    User-Supplied Values

        GOOGLE_REGION                 : europe-west1
        GOOGLE_APPLICATION_CREDENTIALS: /home/rik/studio/profile/service-account.json

    Locally Inferred Values

        gac_project_id                : gcp-secret-manager-0911-1937
        gac_client_email              : service-account@gcp-secret-manager-0911-1937.iam.gserviceaccount.com
        gac_private_key_id            : 8973095309360fd5c2c69a782ad32722e27e4c8a

    Remotely Inferred Values

        gcp_project_id                : gcp-secret-manager-0911-1937
        gcp_project_number            : 710741044927
        gcp_service_account_email     : service-account@gcp-secret-manager-0911-1937.iam.gserviceaccount.com
        gcp_service_account_key_name  : 8973095309360fd5c2c69a782ad32722e27e4c8a
        gcp_service_account_roles     : roles/editor

        gcp_service_names:
            cloudbuild.googleapis.com
            cloudfunctions.googleapis.com
            ...
            secretmanager.googleapis.com
            ...


## GCloud
Warm up with some GCloud commands, executed as an owner.

### Create some Secrets

    echo -n "first secret, first version" |
    gcloud secrets create first-secret\
        --replication-policy=automatic\
        --data-file=-

    echo -n "second secret, first version" |
    gcloud secrets create second-secret\
        --replication-policy=user-managed\
        --locations=$GOOGLE_REGION\
        --data-file=-

    echo -n "third secret, first version" |
    gcloud secrets create third-secret\
        --replication-policy=automatic\
        --data-file=-

### Access the Secrets

    gcloud secrets versions access 1 --secret=first-secret
    gcloud secrets versions access latest --secret=second-secret

(Incidentally, Google's recommendation is not to use latest in production.)

### Increment the Secrets

    echo -n "first secret, second version" |
    gcloud secrets versions add first-secret\
        --data-file=-

    echo -n "second secret, second version" |
    gcloud secrets versions add second-secret\
        --data-file=-

Access the secrets again.

### Delete a Secret

    gcloud secrets list
    gcloud secrets delete third-secret --quiet


## Node
See *quick-start/script.js*.

### Install the Dependencies

    npm install --prefix quick-start @google-cloud/secret-manager

### Enrole the Service Account as a Secret Manager Admin

    gcloud projects add-iam-policy-binding $(gac_project_id)\
        --member=serviceAccount:$(gac_client_email)\
        --role=roles/secretmanager.admin

### Execute the script
This executes as the service account specified by GOOGLE_APPLICATION_CREDENTIALS, to which the admin role has just been bound.

    node quick-start/script.js $(gac_project_id)


## Cloud Function
See *secret-accessor/index.js* and *secret-accessor/.gcloudignore*.

### Enhance the Cloud Function System Service Account

    gcloud projects add-iam-policy-binding $(gac_project_id)\
        --member=serviceAccount:service-$(gcp_project_number)@gcf-admin-robot.iam.gserviceaccount.com\
        --role=roles/storage.objectCreator

### Create and Enrole a Secret-Accessing Service Account
The service account name and display name are derived from the subsequently specified role.  (Note: in this project, the name and the source of the cloud function are also derived from the role; in the index, the name of the exported function is derived from the name of the client method that is used.)

    gcloud iam service-accounts create secret-accessor\
        --display-name=Secret_Accessor\
        --project=$(gac_project_id)

    gcloud projects add-iam-policy-binding $(gac_project_id)\
        --member=serviceAccount:secret-accessor@$(gac_email_suffix)\
        --role=roles/secretmanager.secretAccessor

### Install the Dependencies

    npm install --prefix secret-accessor @google-cloud/secret-manager

### Deploy the Cloud Function

    gcloud functions deploy secret-accessor\
        --set-env-vars=PROJECT_NUMBER=$(gcp_project_number)\
        --service-account=secret-accessor@$(gac_email_suffix)\
        --entry-point=secretVersionAccession\
        --source=secret-accessor\
        --allow-unauthenticated\
        --region=$GOOGLE_REGION\
        --runtime=nodejs12\
        --trigger-http

### Exercise the Cloud Function
This uses GCloud to exercise with some posted name-value pairs.

    export DATA='{"secretName": "first-secret", "secretVersion": 1}'
    gcloud functions call secret-accessor --data="$DATA" --region=$GOOGLE_REGION

This is for a browser to exercise with some query name-value pairs.

    export GCF_HOST="${GOOGLE_REGION}-$(gac_project_id).cloudfunctions.net"
    export GCF_NAME="secret-accessor"
    export GCF_QUERY="secretName=second-secret&secretVersion=1"
    echo "https://$GCF_HOST/$GCF_NAME?$GCF_QUERY"

### Restrict the Secret-Accessing Service Account to a Single Secret
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

### Exercise the Cloud Function Again
This will fail now, although sometimes the condition may take a few minutes to propagate.

    export DATA='{"secretName": "first-secret", "secretVersion": 1}'
    gcloud functions call secret-accessor --data="$DATA" --region=$GOOGLE_REGION

These succeed.

    export DATA='{"secretName": "second-secret", "secretVersion": 1}'
    export DATA='{"secretName": "second-secret", "secretVersion": 2}'
    export DATA='{"secretName": "second-secret", "secretVersion": "latest"}'
    gcloud functions call secret-accessor --data="$DATA" --region=$GOOGLE_REGION
