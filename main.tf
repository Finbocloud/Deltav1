terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.4.0"
    }
  }
}



provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "this-rg"
  location = "uk south"
}

resource "azurerm_virtual_network" "this" {
  name                = "this-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

resource "azurerm_subnet" "this" {
  name                 = "this_subnet"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "this" {
  name                = "this-nic"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.this
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = "this-machine"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = "Standard_F2"
  admin_username      = "eazynet"
  admin_password      = "eazy.net"
  network_interface_ids = [
    azurerm_network_interface.this.id,
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

resource "azurerm_public_ip" "this" {
  name                = "this-pip"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"

}