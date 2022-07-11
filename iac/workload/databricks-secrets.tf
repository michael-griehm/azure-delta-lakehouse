data "azurerm_key_vault" "vault" {
  name                = "dlta-lkehse-kv"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_key_vault_secret" "bronze" {
  name         = "${azurerm_storage_account.bronze.name}-access-key"
  value        = azurerm_storage_account.bronze.primary_access_key
  key_vault_id = data.azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "silver" {
  name         = "${azurerm_storage_account.silver.name}-access-key"
  value        = azurerm_storage_account.silver.primary_access_key
  key_vault_id = data.azurerm_key_vault.vault.id
}

resource "azurerm_key_vault_secret" "gold" {
  name         = "${azurerm_storage_account.gold.name}-access-key"
  value        = azurerm_storage_account.gold.primary_access_key
  key_vault_id = data.azurerm_key_vault.vault.id
}