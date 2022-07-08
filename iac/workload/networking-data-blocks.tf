# data "azurerm_subnet" "storage_private_endpoint" {
#   name                 = "storage-private-endpoint"
#   resource_group_name  = "networking-demo-eastus2"
#   virtual_network_name = "delta-lakehouse-storage-spoke"
# }

# data "azurerm_private_dns_zone" "delta_lakehouse_blobs" {
#   name                = "privatelink.blob.core.windows.net"
#   resource_group_name = "networking-demo-eastus2"
# }

# data "azurerm_private_dns_zone" "delta_lakehouse_dfs" {
#   name                = "privatelink.dfs.core.windows.net"
#   resource_group_name = "networking-demo-eastus2"
# }
