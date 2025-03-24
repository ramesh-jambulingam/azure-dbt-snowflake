

provider "azurerm" {
  features {}
  subscription_id = "<your subscription id>"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location

  tags = var.tags
}

resource "azurerm_container_registry" "acr" {
  name                = "dbtjobs"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_key_vault" "keyvault" {
  name                        = "secrets-aci"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"
  tags = var.tags 
}

resource "azurerm_storage_account" "storageaccount" {
  name                     = "azukssynbasstategsa01pro"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "storagecontainer" {
  name                  = "az-uks-syn-pract-cloud-tfstate-container01-pro"
  storage_account_name  = azurerm_storage_account.storageaccount.name
  container_access_type = "private"
}

# Wait for the storage container before using backend
resource "null_resource" "wait_for_storage" {
  depends_on = [azurerm_storage_container.storagecontainer]
}