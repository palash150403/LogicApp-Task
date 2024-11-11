variable "key_vault_names" {
  # type = set(string)
}
variable "acs_connection_string" {}
variable "analytics_workspace_id" {}
variable "analytics_workspace_connection" {}
variable "managed_api_keyvault_name" {}
variable "managed_api_acs_name" {}
variable "managed_api_azureloganalyticsdatacollector_name" {}
variable "keyvault_api_connection_name" {
  # type = set(string)
}
variable "api_connection_acs_name" {}
variable "api_connection_azureloganalyticsdatacollector_name" {}
variable "logicapp_name" {}
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
variable "vault_name" {}
variable "sender_mail_id" {}
variable "rg_name" {}
variable "reciver_email_ids" {}