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

data "azurerm_subnet" "storage_private_endpoint" {
  name                 = "storage-private-endpoint"
  resource_group_name  = "networking-demo-eastus2"
  virtual_network_name = "delta-lakehouse-storage-spoke"
}

resource "azurerm_private_endpoint" "bronze_private_endpoint" {
  name                = "dltalakehousebronze-private-endpoint"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.storage_private_endpoint.id

  private_service_connection {
    name                           = "dltalakehousebronze-private-service-connection"
    private_connection_resource_id = azurerm_storage_account.bronze.id
    is_manual_connection           = false
    subresource_names              = ["blob", "dfs"]
  }
}

resource "azurerm_storage_account" "silver" {
  name                     = "${local.a_name}-silver"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}

resource "azurerm_storage_account" "gold" {
  name                     = "${local.a_name}-gold"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}