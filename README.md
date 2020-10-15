


# GCP Secret Manager
This project experiments with GCP Secret Manager.  Some secrets that are held by the manger are manipulated from a local command line and from a Cloud Function.  GCloud, Node and JQ are used to manage the APIs, IAMs, GCF and GSM.

> ≡ Top: APIs and Services: Dashboard<br/>
  ≡ Top: IAM and Admin: IAM<br/>
  ≡ Top: IAM and Admin: Service Accounts<br/>
  ≡ Top: Security: Secret Manager<br/>
  ≡ Tools: Cloud Build: Dashboard<br/>
  ≡ Compute: Cloud Functions


## Assumptions
There is a billing-enabled project, with a service account, in GCP.  The project has the Cloud Build, Cloud Functions and Secret Manager APIs enabled.  The $GOOGLE_APPLICATION_CREDENTIALS and $GOOGLE_REGION environment variables have been exported, respectively, containing the (relative or absolute) path to the service account's JSON key file and a desired region.  Logged in as an owner, execute

    source checker.sh; check.sh

It should look something like this (where gac abbreviates Google application credentials):

    Tools

        bash  : GNU bash, version 4.4.20(1)-release (x86_64-pc-linux-gnu)
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
See

* [Quick Start](quick-start)


## Cloud Function
See

* [Secret Accessor](secret-accessor)


## References
* https://cloud.google.com/secret-manager/docs
