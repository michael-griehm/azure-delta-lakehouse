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

# resource "databricks_cluster" "experiment" {
#   cluster_name            = "admin-experiment-cluster"
#   spark_version           = data.databricks_spark_version.latest.id
#   node_type_id            = data.databricks_node_type.smallest.id
#   autotermination_minutes = 15
#   single_user_name        = data.azuread_user.workload_admin.user_principal_name

#   autoscale {
#     min_workers = 1
#     max_workers = 3
#   }

#   spark_conf = {
#     "spark.databricks.passthrough.enabled" : "true"
#   }
# }

resource "databricks_cluster" "high_concurrency_with_aad_passthru_experiment" {
  cluster_name            = "high-concurrency-with-aad-passthru-experiment"
  spark_version           = data.databricks_spark_version.latest.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 15

  autoscale {
    min_workers = 1
    max_workers = 2
  }

  spark_conf = {
    "spark.databricks.cluster.profile" : "serverless",
    "spark.databricks.repl.allowedLanguages" : "python,sql",
    "spark.databricks.passthrough.enabled" : "true",
    "spark.databricks.pyspark.enableProcessIsolation" : "true"
  }
}

resource "databricks_cluster" "no_aad_passthru_experiment" {
  cluster_name            = "no-aad-passthru-experiment"
  spark_version           = data.databricks_spark_version.latest.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 15

  autoscale {
    min_workers = 1
    max_workers = 2
  }
}

# resource "databricks_notebook" "crypto_bronze_to_silver" {
#   source   = "../../notebooks/bronze-to-silver/refine-crypto-today-to-silver.py"
#   path     = "/job-notebooks/bronze-to-silver/refine-crypto-today-to-silver"
#   language = "PYTHON"
# }

# resource "databricks_notebook" "crypto_silver_to_gold" {
#   source   = "../../notebooks/silver-to-gold/refine-crypto-today-to-gold.py"
#   path     = "/job-notebooks/silver-to-gold/refine-crypto-today-to-gold"
#   language = "PYTHON"
# }

# resource "databricks_job" "refine_crypto_today_job" {
#   name = "refine-crypto-today-job"

#   job_cluster {
#     job_cluster_key = "refine-crypto-today-job-cluster"

#     new_cluster {
#       num_workers   = 2
#       spark_version = data.databricks_spark_version.latest.id
#       node_type_id  = data.databricks_node_type.smallest.id
#     }
#   }

#   task {
#     task_key = "a_bronze_to_silver"

#     job_cluster_key = "refine-crypto-today-job-cluster"

#     notebook_task {
#       notebook_path = databricks_notebook.crypto_bronze_to_silver.path
#     }
#   }

#   task {
#     task_key = "b_silver_to_gold"

#     depends_on {
#       task_key = "a_bronze_to_silver"
#     }

#     job_cluster_key = "refine-crypto-today-job-cluster"

#     notebook_task {
#       notebook_path = databricks_notebook.crypto_silver_to_gold.path
#     }
#   }

#   email_notifications {
#     on_start                  = [data.azuread_user.workload_admin.user_principal_name]
#     on_failure                = [data.azuread_user.workload_admin.user_principal_name]
#     on_success                = [data.azuread_user.workload_admin.user_principal_name]
#     no_alert_for_skipped_runs = true
#   }

#   schedule {
#     quartz_cron_expression = "0 45 2,5,14,17,20,23, ? * * *"
#     timezone_id            = "UTC"
#   }
# }

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