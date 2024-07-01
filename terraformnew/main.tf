
  terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.110.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "e9daddad-a704-4272-b124-495fd23ce2ef"
  tenant_id = "665a52fc-90f7-432e-a540-62ee11ad672e"
  client_id = "0ce65b19-a48d-4037-aba3-9b3bb8343bee"
  client_secret = "MmS8Q~fFYXp1LHZPg~EGOlDT7G3P221Q8JDW3a2n"
 features{}

}

resource "azurerm_resource_group" "testrg" {
  name     = "rg1"
  location = "west us 2"
}

resource "azurerm_virtual_network" "testvnet" {
  name                = "vnet1"
  address_space       = ["10.0.0.0/16"]
  location            = "west us 2"
  resource_group_name = "rg1"
  depends_on = [ azurerm_resource_group.testrg ]
}
  resource "azurerm_subnet" "testsubnet" {
  name                 = "sunbet1"
  resource_group_name  = "rg1"
  virtual_network_name = azurerm_virtual_network.testvnet.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_network_interface" "testnic" {
  name                = "nic1"
  location            = "west us 2"
  resource_group_name = "rg1"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.testsubnet.id
    private_ip_address_allocation = "Dynamic"
    
  }
  depends_on = [ azurerm_virtual_network.testvnet,azurerm_subnet.testsubnet ]
}

resource "azurerm_windows_virtual_machine" "testvm" {
  name                = "vm1"
  resource_group_name = "rg1"
  location            = "west us 2"
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "Passw0rd@123"
  network_interface_ids = [
    azurerm_network_interface.testnic.id,
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
  depends_on=[azurerm_network_interface.testnic]
}
  
