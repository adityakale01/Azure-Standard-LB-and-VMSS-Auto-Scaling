resource "azurerm_public_ip" "lb_ip" {
  name                = "publicIPForLB"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
  name                = "TestLoadBalancer"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "web" {
  name            = "web-pool"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "example" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "http-probe"
  port            = 80
  request_path    = "/"
  protocol        = "Http"
}

resource "azurerm_lb_rule" "example" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  disable_outbound_snat          = true
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web.id]
  probe_id                       = azurerm_lb_probe.example.id
}

resource "azurerm_lb_outbound_rule" "example" {
  name                    = "OutboundRule"
  loadbalancer_id         = azurerm_lb.lb.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web.id

  frontend_ip_configuration {
    name = "PublicIPAddress"
  }
}