variable "sku_Name" {}
variable "vault_name" {
  # type = set(string)
}
variable "acs_name" {}
variable "acs_loaction" {}
variable "acs_email_name" {}
variable "log_analytics_workspace_sku" {}
variable "log_analytics_workspace_name" {}
variable "log_workspace_retention_days" {}
variable "managed_api_keyvault_name" {}
variable "managed_api_acs_name" {}
variable "managed_api_azureloganalyticsdatacollector_name" {}
variable "keyvault_api_connection_name" {
  # type = set(string)
}
variable "api_connection_acs_name" {}
variable "api_connection_azureloganalyticsdatacollector_name" {}
variable "logicapp_name" {}
variable "email_communication_service_domain_name" {}
variable "email_communication_service_domain_name_domain_management" {}
variable "keyvault_action_name" {
  # type = list(string)
}
variable "for_each_name" {}
variable "secret_list" {}
variable "expiry_date" {}
variable "current_date" {}
variable "secret_near_expiry" {}
variable "Send_Data" {}
variable "Send_email" {}
variable "Condition" {}
variable "azure_subscription_id" {}
variable "rg_name" {}
variable "reciver_email_ids" {}