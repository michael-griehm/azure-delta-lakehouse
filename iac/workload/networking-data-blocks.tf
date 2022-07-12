locals {
  networking_rg = "networking-demo-eastus2"
}

data "azurerm_virtual_network" "delta_lakehouse_spoke" {
  name                = "delta-lakehouse-spoke"
  resource_group_name = local.networking_rg
}

data "azurerm_subnet" "dbx_public" {
  name                 = "dbx-public"
  resource_group_name  = local.networking_rg
  virtual_network_name = data.azurerm_virtual_network.delta_lakehouse_spoke.name
}

data "azurerm_subnet" "dbx_private" {
  name                 = "dbx-private"
  resource_group_name  = local.networking_rg
  virtual_network_name = data.azurerm_virtual_network.delta_lakehouse_spoke.name
}

data "azurerm_subnet" "storage_private_endpoint" {
  name                 = "storage-private-endpoint"
  resource_group_name  = local.networking_rg
  virtual_network_name = data.azurerm_virtual_network.delta_lakehouse_spoke.name
}

data "azurerm_private_dns_zone" "delta_lakehouse_blobs" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = local.networking_rg
}

data "azurerm_private_dns_zone" "delta_lakehouse_dfs" {
  name                = "privatelink.dfs.core.windows.net"
  resource_group_name = local.networking_rg
}
