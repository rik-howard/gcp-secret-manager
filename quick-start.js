
// Import the Secret Manager client and instantiate it:
let {SecretManagerServiceClient} = require ('@google-cloud/secret-manager');
let client = new SecretManagerServiceClient ();

/**
 * To-do (developer): uncomment these variables before running the sample.
 */
let projectId = `projects/${process.env.GOOGLE_PROJECT}`;  // Project for which to manage secrets.
let secretId  = 'third-secret';                       // Secret ID.
let secretEgo = 'third secret, first version';        // String source data.

async function createAndAccessSecret () {

    // Create the secret with automation replication.
    let [secret] = await client.createSecret ({
        parent: projectId,
        secret: {
            name: secretId,
            replication: {
                automatic: {},
            },
        },
        secretId,
    });

    console.info (`Created secret ${secret.name}`);

    // Add a version with a secretEgo onto the secret.
    let [version] = await client.addSecretVersion ({
        parent: secret.name,
        payload: {
            data: Buffer.from (secretEgo, 'utf8'),
        },
    });

    console.info(`Added secret version ${version.name}`);

    // Access the secret.
    let [accessResponse] = await client.accessSecretVersion ({
        name: version.name,
    });

    let responsePayload = accessResponse.payload.data.toString ('utf8');

    console.info(`Payload: ${responsePayload}`);

}

createAndAccessSecret ();
