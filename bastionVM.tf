resource "azurerm_public_ip" "bastion_ip" {
  name                = "${var.prefix}-bastion-ip"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "bastion_nic" {
  name                = "${var.prefix}-bastion-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet["bastion"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_ip.id
  }
}
resource "azurerm_linux_virtual_machine" "bastion_vm" {
  name                = "${var.prefix}-bastion-vm-1"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = var.vm_size
  admin_username      = "adityaadmin"
  network_interface_ids = [
    azurerm_network_interface.bastion_nic.id,
  ]

  admin_ssh_key {
    username   = "adityaadmin"
    public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}