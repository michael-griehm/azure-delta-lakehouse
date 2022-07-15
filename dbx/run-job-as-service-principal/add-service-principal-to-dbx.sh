curl -X POST 'https://<per-workspace-url>/api/2.0/preview/scim/v2/ServicePrincipals' \
  --header 'Content-Type: application/scim+json' \
  --header 'Authorization: Bearer <personal-access-token>' \
  --data-raw '{
    "schemas":[
      "urn:ietf:params:scim:schemas:core:2.0:ServicePrincipal"
    ],
    "applicationId":"<application-id>",
    "displayName": "test-sp",
    "entitlements":[
      {
        "value":"allow-cluster-create"
      }
    ]
  }'