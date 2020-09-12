
/**
 * Er, ...
 */

let {SecretManagerServiceClient} = require ('@google-cloud/secret-manager');
let client = new SecretManagerServiceClient ();

exports.secretAccessor = async function (request, response) {
    let projectNumber = process.env.PROJECT_NUMBER;
    let secretName = request.query.secretName || request.body.secretName;
    let secretVersion = request.query.secretVersion || request.body.secretVersion;
    response.send (await secretValue (projectNumber, secretName, secretVersion));
}

async function secretValue (projectNumber, secretName, secretVersion) {
    let [response] = await client.accessSecretVersion ({
        name: `projects/${projectNumber}/secrets/${secretName}/versions/${secretVersion}`
    });
    let payload = response.payload;
    let data = payload.data;
    let string = data.toString ("utf8");
    return string;
}
