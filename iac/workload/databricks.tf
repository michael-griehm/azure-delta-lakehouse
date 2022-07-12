resource "azurerm_network_security_group" "dbx_nsg" {
  name                = local.fqrn
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "public_subnet_nsg" {
  subnet_id                 = data.azurerm_subnet.dbx_public.id
  network_security_group_id = azurerm_network_security_group.dbx_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "private_subnet_nsg" {
  subnet_id                 = data.azurerm_subnet.dbx_private.id
  network_security_group_id = azurerm_network_security_group.dbx_nsg.id
}

resource "azurerm_databricks_workspace" "dbx" {
  name                        = "dlta-lakehouse-dbx"
  resource_group_name         = data.azurerm_resource_group.rg.name
  location                    = data.azurerm_resource_group.rg.location
  sku                         = "premium"
  tags                        = var.tags
  managed_resource_group_name = "dlta-lakehouse-dbx-managed"

  custom_parameters {
    virtual_network_id                                   = data.azurerm_virtual_network.delta_lakehouse_spoke.id
    vnet_address_prefix                                  = "10.1"
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public_subnet_nsg.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private_subnet_nsg.id
    public_subnet_name                                   = "dbx-public"
    private_subnet_name                                  = "dbx-private"
    storage_account_name                                 = azurerm_storage_account.dbfs.name
  }

  depends_on = [
    azurerm_storage_account.dbfs,
    azurerm_private_endpoint.dbfs_blob_private_endpoint,
    azurerm_private_endpoint.dbfs_dfs_private_endpoint
  ]
}