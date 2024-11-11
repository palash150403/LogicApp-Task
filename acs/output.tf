output "acs_connection_string" {
  value = azurerm_communication_service.acs.primary_connection_string
}

output "sender_mail_id" {
  value = "DoNotReply@${azurerm_email_communication_service_domain.acs-domain.from_sender_domain}"
}
