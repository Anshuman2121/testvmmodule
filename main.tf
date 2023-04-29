#Resource Group for Virtual Machines.
resource "azurerm_resource_group" "rg-created-by-terraform-1" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet-1" {
  name                = var.vnet
  address_space       = [var.address_space]
  location            = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_subnet" "subnet-1" {
  name                 = "subnet-1"
  resource_group_name  = var.rg_name
  virtual_network_name = var.vnet
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic-1" {
  name                = "nic-1"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "linux-vm-01" {
  name                = "linux-vm-01"
  resource_group_name = var.rg_name
  location            = var.location
  size                = var.vm_size
  admin_username      = "devopsadmin"
  admin_password      = "P@ssw01rd@123"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic-1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

