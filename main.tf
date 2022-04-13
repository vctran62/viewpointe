##### Create Resource Group - good #####
resource "azurerm_resource_group" "rg-tools" {
  name     = "rg-sc-cdw-vpt-dev-tools-01"
  location = "eastus"
}


##### Networking Start - good #####
resource "azurerm_network_security_group" "nsg-tools-01" {
  name                = "nsg-snet-sc-cdw-vpt-dev-tools-01"
  location            = azurerm_resource_group.rg-tools.location
  resource_group_name = azurerm_resource_group.rg-tools.name
}
# vnet also good
resource "azurerm_virtual_network" "vnet-tools-01" {
  name                = "vnet-sc-cdw-vpt-dev-tools-01"
  address_space       = ["10.104.0.0/16"]
  location            = azurerm_resource_group.rg-tools.location
  resource_group_name = azurerm_resource_group.rg-tools.name
  dns_servers = [ "10.255.1.4",
                  "10.255.1.5", ]
}
# 
#resource "azurerm_subnet" "snet-tools-01" {
#  name                 = "snet-sc-cdw-vpt-dev-tools-01"
#  virtual_network_name = azurerm_virtual_network.vnet-tools-01.name
#  resource_group_name  = azurerm_virtual_network.vnet-tools-01.resource_group_name
#  address_prefixes     = ["10.104.1.0/24"]
#  enforce_private_link_endpoint_network_policies = true
#  service_endpoints    = ["Microsoft.Storage"]
#}
resource "azurerm_subnet" "snet-tools-01" {
  name                 = "snet-sc-cdw-vpt-dev-tools-01"
  resource_group_name  = "rg-sc-cdw-vpt-dev-tools-01"
  virtual_network_name = "vnet-sc-cdw-vpt-dev-tools-01"
  address_prefix       = ["10.104.1.0/24"]
  enforce_private_link_endpoint_network_policies = true
  service_endpoints    = ["Microsoft.Storage"]
}
#resource "azurerm_subnet_network_security_group_association" "assoc-tools-01" {
#  subnet_id                 = azurerm_subnet.snet-tools-01.id
#  network_security_group_id = azurerm_network_security_group.nsg-tools-01.id
#}
##### Networking End #####


##### Windows VM Start #####
resource "azurerm_network_interface" "nic-01-sc-vpttools02" {
  name                = "nic-01-sc-vpttools02"
  location            = "eastus"
  resource_group_name = "rg-sc-cdw-vpt-dev-tools-01"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "${azurerm_subnet.snet-tools-01.id}"
#subnet_id                     = "/subscriptions/48c3ee89-06d2-4f41-bedb-22603be48a43/resourceGroups/rg-sc-cdw-vpt-dev-tools-01/providers/Microsoft.Network/virtualNetworks/vnet-sc-cdw-vpt-dev-tools-01/subnets/snet-sc-cdw-vpt-dev-tools-01"
    private_ip_address_allocation = "Dynamic"  
  }
}

resource "azurerm_windows_virtual_machine" "vm-sc-vpttools02" {
  name                            = "sc-vpttools02"
  #resource_group_name             = azurerm_network_interface.nic-01-sc-vpttools02.resource_group_name
  resource_group_name = "rg-sc-cdw-vpt-dev-tools-01"
  location                        = "eastus"
  size                            = "Standard_F1s"
  admin_username                  = "vmadmin"
  admin_password                  = "Adminpw001!"
  tags                            = {
                                      Backup ="Daily"
                                    }
  network_interface_ids = [
    azurerm_network_interface.nic-01-sc-vpttools02.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

}
##### Windows VM End #####
variable "subscriptionId" {}
variable "clientId" {}
variable "clientSecret" {}
variable "tenantId" {}
