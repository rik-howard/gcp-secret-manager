


# Scrap
This file contains some personal details.


## Assumptions
These commands fulfill the assumptions of the read-me.

### Setting up
From the folder containing the read-me, execute the following.

    source path gcloud jq node
    unset NODE_PATH

    source gcloud-configurer $(basename $(pwd))- ~/studio/profile
    export GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_CREDENTIALS
    export GOOGLE_REGION=europe-west1

    source gcloud-builder
    gcloud_set_up cloudbuild cloudfunctions secretmanager

    source checker.sh; cly check.sh
    clear; show_path; show_google; show_foundation


### Resetting up
From the folder containing this read-me, execute the following.

    source checker.sh; cly check.sh

    source path gcloud jq node
    unset NODE_PATH

    export GOOGLE_REGION=europe-west1
    export GOOGLE_APPLICATION_CREDENTIALS=~/studio/profile/service-account.json
    source gcloud-configurer $(gac_project_id) $GOOGLE_APPLICATION_CREDENTIALS $GOOGLE_REGION

    source gcloud-builder
    clear; show_path; show_google; show_foundation
    cly check.sh


### Tearing down
From the folder containing this read-me, execute the following.

    gcloud_tear_down    # to delete everything except the project or
    gcloud_tear_down @  # to delete everything
    clear; show_path; show_google; show_foundation


## GCloud Secrets

* ✓ create
* ✓ delete
* ✗ describe
* ✓ list
* ✗ update
* ✗ get-iam-policy
* ✗ remove-iam-policy
* ✗ set-iam-policy
* ✗ locations describe
* ✗ locations list
* ✓ versions access
* ✗ versions add
* ✗ versions describe
* ✗ versions destroy
* ✗ versions disable
* ✗ versions enable
* ✗ versions list


## Naming

> sasa ~ the secret-accessing service account

| Name                    | Value                  | Derivation                           |
|-------------------------|------------------------|--------------------------------------|
| sasa display name       | Secret_Accessor        | dromedarySnaking (secretManagerRole) |
| sasa name               | secret-accessor        | lowerKebabing (secretManagerRole)    |
| secret manager role     | secretAccessor         | secretManagerRole                    |
| gcf package name        | secret-accessor        | subject ("access-secret")            |
| gcf function name       | secretVersionAccession | process ("accessSecretVersion")      |


### Example and Schema
An *accessive* *accessor* *accesses* an *accessible* *accessee*.

The *accession* causes (effects) an *accessment*.

A <u>subject adjective</u> <u>subject noun</u> <u>verb</u> an <u>object adjecitve</u> <u>object noun</u>.

The <u>process noun</u> causes (effects) a <u>result noun</u>.
