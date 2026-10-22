resource "azurerm_network_security_group" "subnet_nsg" {
  for_each = var.subnet_prefixes

  name                = "${var.prefix}-${each.key}-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}



resource "azurerm_subnet_network_security_group_association" "assoc" {
  for_each = var.subnet_prefixes

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.subnet_nsg[each.key].id
}

resource "azurerm_network_security_group" "vmss_nsg" {
  name                = "${var.prefix}-web-vmss-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_network_security_rule" "vmss_http" {
  name                        = "Allow-HTTP-from-Internet"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.vmss_nsg.name
}

resource "azurerm_network_security_rule" "vmss_ssh" {
  name                        = "Allow-SSH-from-Bastion"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.subnet_prefixes["bastion"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.vmss_nsg.name
}

resource "azurerm_network_security_rule" "bastion_ssh" {
  name                        = "Allow-SSH-Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.my_ip
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.subnet_nsg["bastion"].name
}

resource "azurerm_network_security_rule" "bastion_deny_all" {
  name                        = "Deny-All-Inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.subnet_nsg["bastion"].name
}

resource "azurerm_network_security_rule" "web_ssh" {
  name                        = "Allow-SSH-from-Bastion"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.subnet_prefixes["bastion"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.subnet_nsg["web"].name
}

resource "azurerm_network_security_rule" "web_http" {
  name                        = "Allow-HTTP-from-Internet"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.subnet_nsg["web"].name
}

resource "azurerm_network_security_rule" "app_from_web" {
  name                        = "Allow-App-From-Web"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 8080
  source_address_prefix       = var.subnet_prefixes["web"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.subnet_nsg["app"].name
}

resource "azurerm_network_security_rule" "app_deny_all" {
  name                        = "Deny-All-Inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.subnet_nsg["app"].name
}

resource "azurerm_network_security_rule" "db_from_app" {
  name                        = "Allow-DB-From-App"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 3306
  source_address_prefix       = var.subnet_prefixes["app"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.subnet_nsg["data"].name
}

resource "azurerm_network_security_rule" "db_deny_all" {
  name                        = "Deny-All-Inbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.subnet_nsg["data"].name
}
