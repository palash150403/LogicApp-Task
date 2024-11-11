data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "vault" {
  count                       = length(var.vault_name)
  name                        = var.vault_name[count.index]
  location                    = data.azurerm_resource_group.rg.location
  resource_group_name         = data.azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = var.sku_Name

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id


    key_permissions = [
      "Get", "List", "Update", "Delete", "Recover", "Backup", "Restore", "Create"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Backup", "Purge"
    ]

    storage_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
    ]
  }
}