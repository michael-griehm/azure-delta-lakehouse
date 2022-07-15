curl -X POST 'https://<per-workspace-url/api/2.0/secrets/acls/put' \
  --header 'Authorization: Bearer <personal-access-token>' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "scope": "<scope-name>",
    "principal": "<application-id>",
    "permission": "READ"
  }'