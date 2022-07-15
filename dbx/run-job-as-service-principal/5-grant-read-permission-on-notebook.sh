curl -X PUT 'https://<per-workspace-url>/api/2.0/permissions/notebooks/<notebook-id>' \
  --header 'Authorization: Bearer <personal-access-token>' \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "access_control_list": [
      {
        "service_principal_name": "<application-id>",
        "permission_level": "CAN_READ"
      }
    ]
  }'