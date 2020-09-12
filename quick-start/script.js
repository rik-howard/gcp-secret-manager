
let {SecretManagerServiceClient} = require ('@google-cloud/secret-manager');
let client = new SecretManagerServiceClient ();

let projectId   = process.argv [2];
let secretName  = 'third-secret';
let secretValue = 'third secret, first version';

async function createAndAccessSecret () {

    // Create the secret with automation replication.
    let [secret] = await client.createSecret ({
        parent: `projects/${projectId}`,
        secret: {
            name: secretName,
            replication: {
                automatic: {}
            }
        },
        secretId: secretName
    });

    console.info (`Created secret ${secret.name}`);

    // Add a version with a payload onto the secret.
    let [version] = await client.addSecretVersion ({
        parent: secret.name,
        payload: {
            data: Buffer.from (secretValue, 'utf8'),
        },
    });

    console.info (`Added secret version ${version.name}`);

    // Access the secret.
    let [accessResponse] = await client.accessSecretVersion ({
        name: version.name
    });

    let responsePayload = accessResponse.payload.data.toString ('utf8');

    console.info (`Payload: ${responsePayload}`);

    // Delete the secret.
    let deletionResponses = await client.deleteSecret ({
        name: secret.name
    });

    console.log (`Deletion Response: ${JSON.stringify (deletionResponses)}`);

}

createAndAccessSecret ();
