terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.13.0"
    }

    databricks = {
      source = "databricks/databricks"
    }
  }

  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "admin_user_principal_name" {
  type        = string
  sensitive   = true
  description = "The user principal name of the admin for the app."
  default     = "mikeg@ish-star.com"
}

data "azuread_user" "workload_admin" {
  user_principal_name = var.admin_user_principal_name
}

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "rg" {
  name = "delta-lakehouse-demo-eastus2"
}
