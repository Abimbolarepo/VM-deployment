terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.24.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

resource "azurerm_resource_group" "test1" {
  name     = "test1-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test1" {
  name                = "test1-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test1.location
  resource_group_name = azurerm_resource_group.test1.name
}

resource "azurerm_subnet" "test1" {
  name                 = "test1-subnet"
  resource_group_name  = azurerm_resource_group.test1.name
  virtual_network_name = azurerm_virtual_network.test1.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "test1" {
  name                = "test1-nic"
  location            = azurerm_resource_group.test1.location
  resource_group_name = azurerm_resource_group.test1.name

  ip_configuration {
    name                          = "test1-internal"
    subnet_id                     = azurerm_subnet.test1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "test1" {
  name                = "test1-machine"
  resource_group_name = azurerm_resource_group.test1.name
  location            = azurerm_resource_group.test1.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.test1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}