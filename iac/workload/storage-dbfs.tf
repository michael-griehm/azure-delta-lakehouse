# resource "azurerm_storage_account" "dbfs" {
#   name                     = "dltalakehousedbfs"
#   resource_group_name      = data.azurerm_resource_group.rg.name
#   location                 = data.azurerm_resource_group.rg.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
#   account_kind             = "StorageV2"
#   is_hns_enabled           = "true"

#   network_rules {
#     default_action = "Deny"
#     bypass         = ["AzureServices"]
#   }
# }

# resource "azurerm_private_endpoint" "dbfs_blob_private_endpoint" {
#   name                = "dltalakehousedbfs-blob-private-endpoint"
#   location            = data.azurerm_resource_group.rg.location
#   resource_group_name = data.azurerm_resource_group.rg.name
#   subnet_id           = data.azurerm_subnet.storage_private_endpoint.id

#   private_service_connection {
#     name                           = "dltalakehousedbfs-blob-private-service-connection"
#     private_connection_resource_id = azurerm_storage_account.dbfs.id
#     is_manual_connection           = false
#     subresource_names              = ["blob"]
#   }

#   private_dns_zone_group {
#     name                 = "dltalakehouse-blob-private-dns-zone-group"
#     private_dns_zone_ids = [data.azurerm_private_dns_zone.delta_lakehouse_blobs.id]
#   }
# }

# resource "azurerm_private_endpoint" "dbfs_dfs_private_endpoint" {
#   name                = "dltalakehousedbfs-dfs-private-endpoint"
#   location            = data.azurerm_resource_group.rg.location
#   resource_group_name = data.azurerm_resource_group.rg.name
#   subnet_id           = data.azurerm_subnet.storage_private_endpoint.id

#   private_service_connection {
#     name                           = "dltalakehousedbfs-dfs-private-service-connection"
#     private_connection_resource_id = azurerm_storage_account.dbfs.id
#     is_manual_connection           = false
#     subresource_names              = ["dfs"]
#   }

#   private_dns_zone_group {
#     name                 = "dltalakehouse-dfs-private-dns-zone-group"
#     private_dns_zone_ids = [data.azurerm_private_dns_zone.delta_lakehouse_dfs.id]
#   }
# }