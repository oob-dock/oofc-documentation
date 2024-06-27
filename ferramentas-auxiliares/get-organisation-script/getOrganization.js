#!/usr/bin/env node

const https = require('https');

function makeRequest(url, type, idsList, retryCount) {
    https.get(url, (response) => {
        let data = '';

        response.on('data', (chunk) => {
            data += chunk;
        });

        response.on('end', () => {
            const participants = JSON.parse(data);
            console.log('----------------------------------------------');

            switch(type) {
                case "ORG": mapByOrganisation(idsList, participants); break;
                case "AS": mapByAuthorisationServer(idsList, participants); break;
            }
        });
    }).on('error', error => {
        console.error(`Error: ${error.message}`);

        if (retryCount > 0) {
            console.log(`Retrying request. Retry count: ${retryCount}`);
            makeRequest(url, idsList, retryCount - 1);
        } else {
            console.log("Not possible to get parent organizations for ids informed. Check if Directory API is responding and try again later...");
        }
    }).end();
}

function mapByOrganisation(organisationsId, participants) {
    organisationsId.map((orgId) => {
        const participant = participants.find((p) => p.OrganisationId === orgId);
        if (!participant) {
            console.log(`Organisation Id ${orgId} Not found`);
            console.log('----------------------------------------------');
        } else {
            console.log(`Organisation Id: ${participant.OrganisationId}`);
            console.log(`Organisation Name: ${participant.OrganisationName}`);
            console.log(`Parent Organization: ${!participant.ParentOrganisationReference? "N/A" : participant?.ParentOrganisationReference}`);
            console.log('----------------------------------------------');
        }
    });
}

function mapByAuthorisationServer(authorisationServerIds, participants) {
    authorisationServerIds.map((authId) => {
        const participant = participants.find((p) => p.AuthorisationServers.some(auth => auth.AuthorisationServerId === authId));
        if (!participant) {
            console.log(`Auth ID ${authId} Not found`);
            console.log('----------------------------------------------');
        } else {
            console.log(`Auth ID: ${authId}`);
            console.log(`Organisation Id: ${participant.OrganisationId}`);
            console.log(`Organisation Name: ${participant.OrganisationName}`);
            console.log(`Parent Organization: ${!participant.ParentOrganisationReference ? "N/A" : participant.ParentOrganisationReference}`);
            console.log('----------------------------------------------');
        }
    });
}

async function getParentOrganisationReferences(type, idsList) {
    const url = 'https://data.directory.openbankingbrasil.org.br/participants';
    makeRequest(url, type, idsList, 3);
}

const supportedTypes = ["AS", "ORG"];
const type = process.argv[2];
const idsList = process.argv.slice(3);
if (!supportedTypes.includes(type)) {
    console.log("Invalid type.")
} else {
    getParentOrganisationReferences(type, idsList);
}