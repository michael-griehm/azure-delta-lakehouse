terraform {
  required_providers {
    azurerm = "~> 2.33"
    azuread = "~>2.0"
  }
}

provider "azurerm" {
  features {}
}

variable "app_name" {
  default   = "dlt-lh-smw"
  type      = string
  sensitive = false
}

variable "env" {
  default   = "demo"
  sensitive = false
}

variable "location" {
  default   = "Central US 2"
  sensitive = false
  type      = string
}

variable "tags" {
  type = map(string)

  default = {
    application = "delta-lakehouse-slower-mw"
    environment = "demo"
    workload    = "crypto-analytics"
  }
}

variable "admin_user_principal_name" {
  type        = string
  sensitive   = true
  description = "The user principal name of the admin for the app."
}

locals {
  loc            = lower(replace(var.location, " ", ""))
  a_name         = replace(var.app_name, "-", "")
  fqrn           = "${var.app_name}-${var.env}-${local.loc}"
  fqrn_condensed = "${length(local.a_name) > 22 ? substr(local.a_name, 0, 22) : local.a_name}${substr(local.loc, 0, 1)}${substr(var.env, 0, 1)}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = var.app_name
  location = var.location
}