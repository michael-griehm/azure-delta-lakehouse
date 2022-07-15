resource "azuread_application" "crypto_job" {
  display_name = "${var.app_name}-dbx-crypto-job-runner"
  owners = [
    data.azurerm_client_config.current.object_id,
    data.azuread_user.workload_admin.object_id
  ]
}

resource "azuread_service_principal" "crypto_job" {
  application_id               = azuread_application.crypto_job.application_id
  app_role_assignment_required = false
  owners = [
    data.azurerm_client_config.current.object_id,
    data.azuread_user.workload_admin.object_id
  ]
}

resource "azuread_service_principal_password" "crypto_job" {
  service_principal_id = azuread_service_principal.crypto_job.object_id
}

resource "azurerm_key_vault_secret" "crypto_job_service_principal_client_id" {
  name         = "${azuread_application.crypto_job.display_name}-client-id"
  value        = azuread_service_principal.crypto_job.application_id
  key_vault_id = data.azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "crypto_job_service_principal_secret" {
  name         = "${azuread_application.crypto_job.display_name}-secret"
  value        = azuread_service_principal_password.crypto_job.value
  key_vault_id = data.azurerm_key_vault.vault.id
}

resource "azuread_group_member" "bronze_crypto_quotes_admim_group_member_job" {
  group_object_id  = azuread_group.bronze_crypto_quotes_admin_group.object_id
  member_object_id = azuread_service_principal.crypto_job.object_id
}

resource "azuread_group_member" "silver_crypto_quotes_admim_group_member_job" {
  group_object_id  = azuread_group.silver_crypto_quotes_admin_group.object_id
  member_object_id = azuread_service_principal.crypto_job.object_id
}

resource "azuread_group_member" "gold_crypto_quotes_admim_group_member_job" {
  group_object_id  = azuread_group.gold_crypto_quotes_admin_group.object_id
  member_object_id = azuread_service_principal.crypto_job.object_id
}