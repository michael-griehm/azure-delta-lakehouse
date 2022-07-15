curl -X POST 'https://<per-workspace-url>/api/2.0/secrets/scopes/create' \
--header "Content-Type: application/json" \
--header "Authorization: Bearer <azure-ad-access-token-from-py-script>" \
--data-raw '{
    "scope": "my-simple-azure-keyvault-scope",
    "scope_backend_type": "AZURE_KEYVAULT",
    "backend_azure_keyvault":
    {
      "resource_id": <key-vault-resource-id>,
      "dns_name": <key-vault-url>
    },
    "initial_manage_principal": "users"
  }'