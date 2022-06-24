# terraform/main.tf

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Root module should specify the maximum provider version
      # The ~> operator is a convenient shorthand for allowing only patch releases within a specific minor release.
      version = "~> 2.26"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.environment}-${var.shortloc}-${var.project}"
  location = var.location
  tags = {
    CreatedBy       = "${var.createdby}"
    OwnedBy         = "${var.ownedby}"
    ApplicationName = "${var.tagappname}"
  }
}

# Storage account

resource "azurerm_storage_account" "storage_account" {
  name                     = var.storagename
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    CreatedBy       = "${var.createdby}"
    OwnedBy         = "${var.ownedby}"
    ApplicationName = "${var.tagappname}"
  }
}

# Application Insights

resource "azurerm_application_insights" "application_insights" {
  name                = "${var.environment}-${var.shortloc}-${var.project}"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "web"
  tags = {
    CreatedBy       = "${var.createdby}"
    OwnedBy         = "${var.ownedby}"
    ApplicationName = "${var.tagappname}"
  }
}

# App Service Plan

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.environment}-${var.shortloc}-${var.project}ASP"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  kind                = "FunctionApp"
  reserved            = false # this has to be set to true for Linux. Not related to the Premium Plan
  sku {
    tier = "Standard"
    size = "S1"
  }
  tags = {
    CreatedBy       = "${var.createdby}"
    OwnedBy         = "${var.ownedby}"
    ApplicationName = "${var.tagappname}"
  }
}

# Function App
resource "azurerm_function_app" "function_app" {
  name                = "${var.environment}-${var.shortloc}-${var.project}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"       = "",
    "FUNCTIONS_WORKER_RUNTIME"       = "dotnet",
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.application_insights.instrumentation_key,
    "FUNCTIONS_EXTENSION_VERSION" : "~4"
  }
  site_config {
    use_32_bit_worker_process = false
    always_on                 = true
  }
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  version                    = "~3"

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
  tags = {
    CreatedBy       = "${var.createdby}"
    OwnedBy         = "${var.ownedby}"
    ApplicationName = "${var.tagappname}"
  }
}