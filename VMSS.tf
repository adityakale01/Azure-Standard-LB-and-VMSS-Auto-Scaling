
resource "azurerm_linux_virtual_machine_scale_set" "VMSS" {
  name                = "trail-vmss"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = var.vm_size
  instances           = 2
  admin_username      = "adityaadmin"

  upgrade_mode  = "Manual"
  overprovision = false

  custom_data = filebase64("${path.module}/web-init.yaml")

  admin_ssh_key {
    username   = "adityaadmin"
    public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                      = "${var.prefix}-vmss-nic"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.vmss_nsg.id

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.subnet["web"].id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web.id]
    }
  }
  lifecycle {
    ignore_changes = [instances]
  }
  depends_on = [azurerm_lb_rule.example]
}