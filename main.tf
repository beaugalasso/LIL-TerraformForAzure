terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.76.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

# Creates resource group
resource "azurerm_resource_group" "main" {
  name = "learn-tf-rg-eastus"
  location = "eastus"
}

# Creates virtual network
resource "azurerm_virtual_network" "main" {
  name = "learn-tf-vnet-eastus"
  location = azurerm_resource_group.main.location # Uses same location as RG above
  resource_group_name = azurerm_resource_group.main.name # Uses RG created above
  address_space = ["10.0.0.0/16"]
}

# Create subnet
resource "azurerm_subnet" "main" {
  name = "learn-tf-subnet-eastus"
  resource_group_name = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = ["10.0.0.0/24"]
}

# Create internal NIC
resource "azurerm_network_interface" "internal" {
    name = "learn-tf-nic-int-eastus"
    location = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    ip_configuration {
      name = "internal"
      subnet_id = azurerm_subnet.main.id # References Resource ID of subnet created above
      private_ip_address_allocation = "Dynamic"
    }  
}

# Create VM
resource "azurerm_windows_virtual_machine" "main" {
  name = "learn-tf-vm-eu"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  size = "Standard_B1s"
  admin_username = "user.admin"
  admin_password = "12978fh91-j-29308j1"
  
  network_interface_ids = [
    azurerm_network_interface.internal.id
  ]
  
  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer = "WindowsServer"
    sku = "2016-DataCenter"
    version = "latest"
  }
}
