output "rg_name" {
  value = data.azurerm_resource_group.rg.id
}

output "key_vault_names" {
  value = [for kv in azurerm_key_vault.vault : kv.name]
}