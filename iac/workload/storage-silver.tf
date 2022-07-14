resource "azurerm_storage_account" "silver" {
  name                     = "dltalakehousesilver"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }
}

resource "azurerm_role_assignment" "silver_deployer_role_assignment" {
  scope                = azurerm_storage_account.silver.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_private_endpoint" "silver_blob_private_endpoint" {
  name                = "dltalakehousesilver-blob-private-endpoint"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.storage_private_endpoint.id

  private_service_connection {
    name                           = "dltalakehousesilver-blob-private-service-connection"
    private_connection_resource_id = azurerm_storage_account.silver.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "privatelink.blob.core.windows.net"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.delta_lakehouse_blobs.id]
  }
}

resource "azurerm_private_endpoint" "silver_dfs_private_endpoint" {
  name                = "dltalakehousesilver-dfs-private-endpoint"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.storage_private_endpoint.id

  private_service_connection {
    name                           = "dltalakehousesilver-dfs-private-service-connection"
    private_connection_resource_id = azurerm_storage_account.silver.id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "privatelink.dfs.core.windows.net"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.delta_lakehouse_dfs.id]
  }
}

resource "azuread_group" "silver_crypto_quotes_admin_group" {
  display_name     = "delta-lakehouse-silver-crypto-quotes-admin"
  security_enabled = true

  owners = [
    data.azurerm_client_config.current.object_id,
    data.azuread_user.workload_admin.object_id
  ]
}

resource "azuread_group_member" "silver_crypto_quotes_admin_group_member" {
  group_object_id  = azuread_group.silver_crypto_quotes_admin_group.object_id
  member_object_id = data.azuread_user.workload_admin.object_id
}

resource "azuread_group_member" "silver_crypto_quotes_admim_group_member_deployer" {
  group_object_id  = azuread_group.silver_crypto_quotes_admin_group.object_id
  member_object_id = data.azurerm_client_config.current.object_id
}

resource "azuread_group" "silver_crypto_quotes_writer_group" {
  display_name     = "delta-lakehouse-silver-crypto-quotes-writer"
  security_enabled = true

  owners = [
    data.azurerm_client_config.current.object_id,
    data.azuread_user.workload_admin.object_id
  ]
}

resource "azuread_group" "silver_crypto_quotes_reader_group" {
  display_name     = "delta-lakehouse-silver-crypto-quotes-reader"
  security_enabled = true

  owners = [
    data.azurerm_client_config.current.object_id,
    data.azuread_user.workload_admin.object_id
  ]
}

resource "azurerm_storage_data_lake_gen2_filesystem" "silver_crypto" {
  name               = "crypto-data"
  storage_account_id = azurerm_storage_account.silver.id

  ace {
    scope       = "default"
    type        = "group"
    id          = azuread_group.silver_crypto_quotes_admin_group.object_id
    permissions = "rwx"
  }
  ace {
    scope       = "access"
    type        = "group"
    id          = azuread_group.silver_crypto_quotes_admin_group.object_id
    permissions = "rwx"
  }
  ace {
    scope       = "default"
    type        = "group"
    id          = azuread_group.silver_crypto_quotes_reader_group.object_id
    permissions = "r--"
  }
  ace {
    scope       = "access"
    type        = "group"
    id          = azuread_group.silver_crypto_quotes_reader_group.object_id
    permissions = "r--"
  }
  ace {
    scope       = "default"
    type        = "group"
    id          = azuread_group.silver_crypto_quotes_writer_group.object_id
    permissions = "-w-"
  }
  ace {
    scope       = "access"
    type        = "group"
    id          = azuread_group.silver_crypto_quotes_writer_group.object_id
    permissions = "-w-"
  }

  depends_on = [
    azurerm_role_assignment.silver_deployer_role_assignment
  ]
}
