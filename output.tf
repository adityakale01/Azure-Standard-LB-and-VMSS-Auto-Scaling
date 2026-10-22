output "lb_public_ip" {
  value = azurerm_public_ip.lb_ip.ip_address
}

output "bastion_public_ip" {
  value = azurerm_public_ip.bastion_ip.ip_address
}

output "vmss_name" {
  value = azurerm_linux_virtual_machine_scale_set.VMSS.name
}