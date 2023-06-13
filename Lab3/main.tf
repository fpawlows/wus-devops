provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "WUS3RG" {
  name     = "WUS3RG"
  location = "westeurope"
}
