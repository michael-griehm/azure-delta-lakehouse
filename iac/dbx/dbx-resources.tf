data "azurerm_databricks_workspace" "dbx" {
  name                = "dlta-lakehouse-dbx"
  resource_group_name = data.azurerm_resource_group.rg.name
}

provider "databricks" {
  host                        = data.azurerm_databricks_workspace.dbx.workspace_url
  azure_workspace_resource_id = data.azurerm_databricks_workspace.dbx.id
  azure_client_id             = data.azurerm_client_config.current.client_id
  azure_tenant_id             = data.azurerm_client_config.current.tenant_id
  azure_client_secret         = var.client_secret
}

data "databricks_spark_version" "latest" {}

data "databricks_node_type" "smallest" {
  local_disk = true
}

# resource "databricks_user" "dbx_admin" {
#   user_name = data.azuread_user.workload_admin.user_principal_name
# }

resource "databricks_cluster" "experiment" {
  cluster_name            = "admin-experiment-cluster"
  spark_version           = data.databricks_spark_version.latest.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 15
  single_user_name        = data.azuread_user.workload_admin.user_principal_name

  autoscale {
    min_workers = 1
    max_workers = 3
  }

  spark_conf = {
    "spark.databricks.passthrough.enabled" : "true"
  }
}

data "azurerm_key_vault" "secret_scope_vault" {
  resource_group_name = data.azurerm_resource_group.rg.name
  name                = "dlta-lkehse-kv"
}

output "azurerm_databricks_workspace_url" {
  value = data.azurerm_databricks_workspace.dbx.workspace_url
}

output "secret_scope_vault_id" {
  value = data.azurerm_key_vault.secret_scope_vault.id
}

output "secret_scope_vault_hostname" {
  value = data.azurerm_key_vault.secret_scope_vault.vault_uri
}