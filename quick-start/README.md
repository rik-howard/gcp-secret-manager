


# Quick Start
See

* [script.js](script.js)

The script is essentially the same as the one from the official [docs](https://cloud.google.com/secret-manager/docs/quickstart).  The NPM and Node commands, below, assume that they are being run from the folder containing this read-me.

### Install the Dependencies

    npm install @google-cloud/secret-manager

### Enrole the Service Account as a Secret Manager Admin

    gcloud projects add-iam-policy-binding $(gac_project_id)\
        --member=serviceAccount:$(gac_client_email)\
        --role=roles/secretmanager.admin

### Execute the script
This executes as the service account specified by GOOGLE_APPLICATION_CREDENTIALS, to which the admin role has just been bound.

    node script.js $(gac_project_id)
