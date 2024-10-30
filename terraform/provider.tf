terraform {
  backend "azurerm" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.99.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.1"
    }
  }
}

provider "azurerm" {
  tenant_id       = var.customer.tenantid
  subscription_id = var.customer.subscriptionid
  features {}
}

provider "local" {}