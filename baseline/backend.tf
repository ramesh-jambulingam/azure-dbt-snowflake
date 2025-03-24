terraform {
  backend "azurerm" {
    resource_group_name  = "az-uks-syn-poc-pract-dbt-rg01-poc"
    storage_account_name = "azukssynbasstategsa01pro"
    container_name       = "az-uks-syn-pract-cloud-tfstate-container01-pro"
    key                  = "dbt_baseline.terraform.tfstate"
  }
}
