#####################
#                   #
#     Réseau        #
#                   #
#####################

resource "azurerm_virtual_network" "main" {
  name                = "vnet${var.trigram}01"
  address_space       = var.vnet_address_space
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_subnet" "sn-vm" {
  name                 = "sn-vms"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.vm_subnet_address_prefixe
}

resource "azurerm_subnet" "web-appgateway" {
  name                 = "web-appgateway"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.agw_subnet_address_prefixe
}

resource "azurerm_network_interface" "nic-vm1" {
  name                = "nic${var.trigram}vm01"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sn-vm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "IP_Public_agw" {
  name                = "IP_Public_${var.trigram}"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  allocation_method   = "Static"
  domain_name_label   = var.trigram

  tags = {
    environment = "Production"
  }
}

#################
#               #
#      VM       #
#               #
#################

resource "azurerm_windows_virtual_machine" "vm-WindowsServer1" {
  name                = "vm${var.trigram}srv01"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  size                = "Standard_B2s_v2"
  admin_username      = var.vm_username
  admin_password      = var.vm_password

  network_interface_ids = [
    azurerm_network_interface.nic-vm1.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  depends_on = [azurerm_network_security_group.nsg1]
}

# Install IIS web server to the virtual machine
resource "azurerm_virtual_machine_extension" "web_server_install" {
  name                       = "web-wsi"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm-WindowsServer1.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
  SETTINGS
}

# Change the default IIS start page title
resource "azurerm_virtual_machine_run_command" "iis_default_page_title" {
  name               = "iis-default-page-title"
  location           = data.azurerm_resource_group.main.location
  virtual_machine_id = azurerm_windows_virtual_machine.vm-WindowsServer1.id

  source {
    script = "powershell -ExecutionPolicy Unrestricted -Command (Get-Content 'C:\\inetpub\\wwwroot\\iisstart.htm') | % {$_ -replace 'IIS Windows Server','${var.trigram}-${data.azurerm_resource_group.main.location}'} | Set-Content 'C:\\inetpub\\wwwroot\\iisstart.htm'"
  }

  depends_on = [azurerm_virtual_machine_extension.web_server_install]
}

#####################################
#                                   #
#     Network Security Group        #
#                                   #
#####################################

resource "azurerm_network_security_group" "nsg1" {
  name                = "nsg${var.trigram}01"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
}

resource "azurerm_subnet_network_security_group_association" "nsg1-sn-vms" {
  subnet_id                 = azurerm_subnet.sn-vm.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

##################################
#                                #
#     Application Gateway        #
#                                #
##################################

# puisque ces variables sont réutilisées - un bloc local permet de mieux les maintenir

locals {
  backend_address_pool_web       = "${azurerm_virtual_network.main.name}-beap"
  frontend_port_HTTP             = "${azurerm_virtual_network.main.name}-feport"
  frontend_ip_configuration_HTTP = "${azurerm_virtual_network.main.name}-feip"
  http_setting_web               = "${azurerm_virtual_network.main.name}-be-htst"
  listener_HTTP                  = "${azurerm_virtual_network.main.name}-httplstn"
  request_routing_rule_HTTP      = "${azurerm_virtual_network.main.name}-rqrt"
}

resource "azurerm_application_gateway" "WEB" {
  name                = "web-appgateway"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "web-ip-configuration"
    subnet_id = azurerm_subnet.web-appgateway.id
  }

  frontend_port {
    name = local.frontend_port_HTTP
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_HTTP
    public_ip_address_id = azurerm_public_ip.IP_Public_agw.id
  }

  backend_address_pool {
    name         = local.backend_address_pool_web
    ip_addresses = azurerm_network_interface.nic-vm1.private_ip_addresses
  }

  backend_http_settings {
    name                  = local.http_setting_web
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_HTTP
    frontend_ip_configuration_name = local.frontend_ip_configuration_HTTP
    frontend_port_name             = local.frontend_port_HTTP
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_HTTP
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_HTTP
    backend_address_pool_name  = local.backend_address_pool_web
    backend_http_settings_name = local.http_setting_web
  }
}

######################
#                    #
#     PEERING        #
#                    #
######################

resource "azurerm_virtual_network_peering" "PeeringtoHUB" {
  name                      = "${var.trigram}toHUB"
  resource_group_name       = data.azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.main.name
  remote_virtual_network_id = var.remote_virtual_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
}

##############################
#                            #
#     Traffic Manager        #
#                            #
##############################

resource "azurerm_traffic_manager_azure_endpoint" "hub" {
  name               = "${var.trigram}-endpoint"
  profile_id         = var.traffic_manager_id
  target_resource_id = azurerm_public_ip.IP_Public_agw.id
  priority           = var.tm_endpoint_priority
}
