terraform {
  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.99.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  sku_name = "Standard_v2"
  sku_tier = "Standard_v2"

  backend_address_pool_name      = "${var.name}-beap"
  frontend_port_name             = "${var.name}-feport"
  frontend_ip_configuration_name = "${var.name}-feip"
  http_setting_name              = "${var.name}-be-htst"
  listener_name                  = "${var.name}-httplstn"
  request_routing_rule_name      = "${var.name}-rqrt"

}

#
# Resource group
#

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

#
# Public IP
#

resource "azurerm_public_ip" "main" {
  name                = "${var.name}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"

}

#
# Application Gateway
#

resource "azurerm_application_gateway" "main" {
  name                = "${var.name}-appgw"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  enable_http2        = true
  zones               = var.zones
  firewall_policy_id  = azurerm_web_application_firewall_policy.main.id


  sku {
    name = local.sku_name
    tier = local.sku_tier
  }

  autoscale_configuration {
    min_capacity = var.capacity.min
    max_capacity = var.capacity.max
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  gateway_ip_configuration {
    name      = "${var.name}-gateway-ip-configuration"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "${local.frontend_ip_configuration_name}-public"
    public_ip_address_id = azurerm_public_ip.main.id
  }

  frontend_ip_configuration {
    name                          = "${local.frontend_ip_configuration_name}-private"
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip_address
    subnet_id                     = var.subnet_id
  }

  frontend_port {
    name = "${local.frontend_port_name}-80"
    port = 80
  }

  frontend_port {
    name = "${local.frontend_port_name}-443"
    port = 443
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/ping/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = "${local.frontend_ip_configuration_name}-private"
    frontend_port_name             = "${local.frontend_port_name}-80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = var.ssl_policy_name
  }
