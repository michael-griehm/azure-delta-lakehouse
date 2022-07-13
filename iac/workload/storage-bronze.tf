resource "azurerm_storage_account" "bronze" {
  name                     = "dltalakehousebronze"
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

resource "azurerm_private_endpoint" "bronze_blob_private_endpoint" {
  name                = "dltalakehousebronze-blob-private-endpoint"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.storage_private_endpoint.id

  private_service_connection {
    name                           = "dltalakehousebronze-blob-private-service-connection"
    private_connection_resource_id = azurerm_storage_account.bronze.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "dltalakehouse-blob-private-dns-zone-group"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.delta_lakehouse_blobs.id]
  }
}

resource "azurerm_private_endpoint" "bronze_dfs_private_endpoint" {
  name                = "dltalakehousebronze-dfs-private-endpoint"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.storage_private_endpoint.id

  private_service_connection {
    name                           = "dltalakehousebronze-dfs-private-service-connection"
    private_connection_resource_id = azurerm_storage_account.bronze.id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "dltalakehouse-dfs-private-dns-zone-group"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.delta_lakehouse_dfs.id]
  }
}

resource "azuread_group" "bronze_crypto_quotes_admin_group" {
  display_name     = "delta-lakehouse-bronze-crypto-quotes-admin"
  security_enabled = true

  owners = [
    data.azurerm_client_config.current.object_id,
    data.azuread_user.workload_admin.object_id
  ]
}

resource "azuread_group_member" "bronze_crypto_quotes_admin_group_member" {
  group_object_id  = azuread_group.bronze_crypto_quotes_admin_group.object_id
  member_object_id = data.azuread_user.workload_admin.object_id
}

resource "azuread_group_member" "bronze_crypto_quotes_admim_group_member_deployer" {
  group_object_id  = azuread_group.bronze_crypto_quotes_admin_group.object_id
  member_object_id = data.azurerm_client_config.current.object_id
}

resource "azuread_group" "bronze_crypto_quotes_writer_group" {
  display_name     = "delta-lakehouse-bronze-crypto-quotes-writer"
  security_enabled = true

  owners = [
    data.azurerm_client_config.current.object_id,
    data.azuread_user.admin.object_id
  ]
}

resource "azuread_group" "bronze_crypto_quotes_reader_group" {
  display_name     = "delta-lakehouse-bronze-crypto-quotes-reader"
  security_enabled = true

  owners = [
    data.azurerm_client_config.current.object_id,
    data.azuread_user.admin.object_id
  ]
}

resource "azurerm_storage_container" "bronze_crypto" {
  name                  = "crypto-stream"
  storage_account_name  = azurerm_storage_account.bronze.name
  container_access_type = "private"

  ace {
    scope       = "default"
    type        = "group"
    id          = azuread_group.bronze_crypto_quotes_admin_group.object_id
    permissions = "rwx"
  }
  ace {
    scope       = "access"
    type        = "group"
    id          = azuread_group.bronze_crypto_quotes_admin_group.object_id
    permissions = "rwx"
  }
  ace {
    scope       = "default"
    type        = "group"
    id          = azuread_group.bronze_crypto_quotes_reader_group.object_id
    permissions = "r--"
  }
  ace {
    scope       = "access"
    type        = "group"
    id          = azuread_group.bronze_crypto_quotes_reader_group.object_id
    permissions = "r--"
  }
  ace {
    scope       = "default"
    type        = "group"
    id          = azuread_group.bronze_crypto_quotes_writer_group.object_id
    permissions = "-w-"
  }
  ace {
    scope       = "access"
    type        = "group"
    id          = azuread_group.bronze_crypto_quotes_writer_group.object_id
    permissions = "-w-"
  }
}
