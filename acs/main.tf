resource "azurerm_communication_service" "acs" {
  name                = var.acs_name
  resource_group_name = var.resource_group
  data_location       = var.acs_loaction
}

resource "azurerm_email_communication_service" "acs_email" {
  name                = var.acs_email_name
  resource_group_name = var.resource_group
  data_location       = var.acs_loaction
}

resource "azurerm_email_communication_service_domain" "acs-domain" {
  name              = var.email_communication_service_domain_name
  email_service_id  = azurerm_email_communication_service.acs_email.id
  domain_management = var.email_communication_service_domain_name_domain_management
}

resource "azurerm_communication_service_email_domain_association" "domain_association" {
  communication_service_id = azurerm_communication_service.acs.id
  email_service_domain_id  = azurerm_email_communication_service_domain.acs-domain.id
}
