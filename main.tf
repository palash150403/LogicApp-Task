data "azurerm_resource_group" "rg" {
  name = var.rg_name
}


module "KeyVault" {
  source     = "./KeyVault"
  sku_Name   = var.sku_Name
  vault_name = var.vault_name
  rg_name = var.rg_name
}

module "acs" {
  source                                                    = "./acs"
  resource_group                                            = data.azurerm_resource_group.rg.name
  acs_name                                                  = var.acs_name
  acs_loaction                                              = var.acs_loaction
  acs_email_name                                            = var.acs_email_name
  email_communication_service_domain_name                   = var.email_communication_service_domain_name
  email_communication_service_domain_name_domain_management = var.email_communication_service_domain_name_domain_management
}

module "log_analytics_workspace" {
  source                       = "./LogAnalytics"
  log_analytics_workspace_name = var.log_analytics_workspace_name
  log_analytics_workspace_sku  = var.log_analytics_workspace_sku
  log_workspace_retention_days = var.log_workspace_retention_days
  rg_name = var.rg_name
}

module "LogicApp" {
  source                                             = "./LogicApp"
  key_vault_names                                    = var.vault_name
  acs_connection_string                              = module.acs.acs_connection_string
  analytics_workspace_connection                     = module.log_analytics_workspace.analytics_workspace_connection
  analytics_workspace_id                             = module.log_analytics_workspace.analytics_workspace_id
  managed_api_keyvault_name                          = var.managed_api_keyvault_name
  managed_api_acs_name                               = var.managed_api_acs_name
  managed_api_azureloganalyticsdatacollector_name    = var.managed_api_azureloganalyticsdatacollector_name
  keyvault_api_connection_name                       = var.keyvault_api_connection_name
  api_connection_acs_name                            = var.api_connection_acs_name
  logicapp_name                                      = var.logicapp_name
  api_connection_azureloganalyticsdatacollector_name = var.api_connection_azureloganalyticsdatacollector_name
  keyvault_action_name                               = var.keyvault_action_name
  for_each_name                                      = var.for_each_name
  secret_list                                        = var.secret_list
  expiry_date                                        = var.expiry_date
  current_date                                       = var.current_date
  secret_near_expiry                                 = var.secret_near_expiry
  Send_Data                                          = var.Send_Data
  Send_email                                         = var.Send_email
  Condition                                          = var.Condition
  vault_name                                         = var.vault_name
  sender_mail_id = module.acs.sender_mail_id
  rg_name = var.rg_name
  reciver_email_ids = var.reciver_email_ids

}