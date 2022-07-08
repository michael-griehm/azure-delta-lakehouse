resource "azurerm_storage_account" "silver" {
  name                     = "dltalakehousesilver"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"

  network_rules {
    default_action = "Allow"
    bypass         = ["AzureServices"]
  }
}

# resource "azurerm_private_endpoint" "silver_blob_private_endpoint" {
#   name                = "dltalakehousesilver-blob-private-endpoint"
#   location            = data.azurerm_resource_group.rg.location
#   resource_group_name = data.azurerm_resource_group.rg.name
#   subnet_id           = data.azurerm_subnet.storage_private_endpoint.id

#   private_service_connection {
#     name                           = "dltalakehousesilver-blob-private-service-connection"
#     private_connection_resource_id = azurerm_storage_account.bronze.id
#     is_manual_connection           = false
#     subresource_names              = ["blob"]
#   }

#   private_dns_zone_group {
#     name                 = "privatelink.blob.core.windows.net"
#     private_dns_zone_ids = [data.azurerm_private_dns_zone.delta_lakehouse_blobs.id]
#   }
# }

# resource "azurerm_private_endpoint" "silver_dfs_private_endpoint" {
#   name                = "dltalakehousesilver-dfs-private-endpoint"
#   location            = data.azurerm_resource_group.rg.location
#   resource_group_name = data.azurerm_resource_group.rg.name
#   subnet_id           = data.azurerm_subnet.storage_private_endpoint.id

#   private_service_connection {
#     name                           = "dltalakehousesilver-dfs-private-service-connection"
#     private_connection_resource_id = azurerm_storage_account.bronze.id
#     is_manual_connection           = false
#     subresource_names              = ["dfs"]
#   }

#   private_dns_zone_group {
#     name                 = "privatelink.dfs.core.windows.net"
#     private_dns_zone_ids = [data.azurerm_private_dns_zone.delta_lakehouse_dfs.id]
#   }
# }

resource "azurerm_storage_container" "silver_crypto" {
  name                  = "crypto-data"
  storage_account_name  = azurerm_storage_account.silver.name
  container_access_type = "private"
}