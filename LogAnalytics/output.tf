output "analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.example.workspace_id
}

output "analytics_workspace_connection" {
  value = azurerm_log_analytics_workspace.example.primary_shared_key
}