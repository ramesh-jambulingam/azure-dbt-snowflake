

provider "azurerm" {
  features {}
  subscription_id = "13cdc8f1-c0a8-44d5-9b44-950f0ba058a8"
}

locals {
  image_name = "dbtjobs.azurecr.io/dbt/tpch_transform:${var.image_version}"
}

data "terraform_remote_state" "azure_baseline" {
  backend = "azurerm"
  config = {
    resource_group_name  = "az-uks-syn-poc-pract-dbt-rg01-poc"
    storage_account_name = "azukssynbasstategsa01pro"
    container_name       = "az-uks-syn-pract-cloud-tfstate-container01-pro"
    key                  = "dbt_baseline.terraform.tfstate"
  }
}

resource "azurerm_container_group" "aci" {
  name                = "dbt-job-example"
  location            = var.location
  resource_group_name = var.rg_name
  ip_address_type     = "Public"
  os_type             = "Linux"
  restart_policy      = "Never"

  container {
    name   = "dbt"
    image  = local.image_name
    cpu    = "0.5"
    memory = "1"

    ports {
      port     = 80
      protocol = "TCP"
    }
    environment_variables = {
      ENV_KV_URL = "https://secrets-aci.vault.azure.net"
      ENV_SNOW_SECRET = "snowflake-certificate"
    }
  }

  image_registry_credential {
    server                    = "dbtjobs.azurecr.io"
    username = data.terraform_remote_state.azure_baseline.outputs.acr_admin_username
    password = data.terraform_remote_state.azure_baseline.outputs.acr_admin_password
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

data "azurerm_key_vault" "secrets" {
  name                = "secrets-aci"
  resource_group_name = var.rg_name
}

resource "azurerm_role_assignment" "keyvault" {
  scope                = data.azurerm_key_vault.secrets.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_container_group.aci.identity.0.principal_id
}