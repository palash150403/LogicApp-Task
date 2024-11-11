data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azurerm_client_config" "current" {}




data "azurerm_managed_api" "managed_api" {
  name     = var.managed_api_keyvault_name
  location = data.azurerm_resource_group.rg.location
}

data "azurerm_managed_api" "managed_api_acs" {
  name     = var.managed_api_acs_name
  location = data.azurerm_resource_group.rg.location
}

data "azurerm_managed_api" "managed_api_azureloganalyticsdatacollector" {
  name     = var.managed_api_azureloganalyticsdatacollector_name
  location = data.azurerm_resource_group.rg.location
}


### API Connections
resource "azurerm_api_connection" "api_connection" {
  count               = length(var.keyvault_api_connection_name)
  name                = var.keyvault_api_connection_name[count.index]
  resource_group_name = data.azurerm_resource_group.rg.name
  managed_api_id      = data.azurerm_managed_api.managed_api.id
  display_name        = var.keyvault_api_connection_name[count.index]


  parameter_values = {

    vaultName = var.key_vault_names[count.index]
  }
}

resource "azurerm_api_connection" "api_connection_acs" {
  name                = var.api_connection_acs_name
  resource_group_name = data.azurerm_resource_group.rg.name
  managed_api_id      = data.azurerm_managed_api.managed_api_acs.id
  display_name        = var.api_connection_acs_name


  parameter_values = {
    api_key = var.acs_connection_string
  }
}

resource "azurerm_api_connection" "api_connection_azureloganalyticsdatacollector" {
  name                = var.api_connection_azureloganalyticsdatacollector_name
  resource_group_name = data.azurerm_resource_group.rg.name
  managed_api_id      = data.azurerm_managed_api.managed_api_azureloganalyticsdatacollector.id
  display_name        = var.api_connection_azureloganalyticsdatacollector_name


  parameter_values = {
    username = var.analytics_workspace_id
    password = var.analytics_workspace_connection
  }
}



### Workflow
resource "azurerm_logic_app_workflow" "logicapp" {
  name                = var.logicapp_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  workflow_parameters = {
    "$connections" = jsonencode(
      {
        defaultValue = {}
        type         = "Object"
      }
    )
  }

  parameters = {
    "$connections" = jsonencode(
      merge(
        {
          for idx, keyvault_name in var.key_vault_names :
          keyvault_name => {
            "connectionId"   = azurerm_api_connection.api_connection[idx].id
            "connectionName" = azurerm_api_connection.api_connection[idx].name
            "id"             = azurerm_api_connection.api_connection[idx].managed_api_id
          }
        },
        {
          "acsemail" = {
            "id"             = azurerm_api_connection.api_connection_acs.managed_api_id
            "connectionId"   = azurerm_api_connection.api_connection_acs.id
            "connectionName" = azurerm_api_connection.api_connection_acs.name
          }
        },
        {
          "azureloganalyticsdatacollector" = {
            "id"             = azurerm_api_connection.api_connection_azureloganalyticsdatacollector.managed_api_id
            "connectionId"   = azurerm_api_connection.api_connection_azureloganalyticsdatacollector.id
            "connectionName" = azurerm_api_connection.api_connection_azureloganalyticsdatacollector.name
          }
        }
      )
    )
  }
}

#28
resource "azurerm_logic_app_trigger_custom" "Recurrence_trigger" {
  name         = "Recurrence"
  logic_app_id = azurerm_logic_app_workflow.logicapp.id

  body = <<BODY
    {
        "type": "Recurrence",
        "recurrence": {
            "interval": 3,
            "frequency": "Hour",
            "timeZone": "India Standard Time"
        }
    }
    BODY

}

resource "azurerm_logic_app_action_custom" "keyvault_action" {
  count        = length(var.keyvault_action_name)
  name         = var.keyvault_action_name[count.index]
  logic_app_id = azurerm_logic_app_workflow.logicapp.id

  body = <<BODY
{
  "type": "ApiConnection",
  "inputs": {
    "host": {
      "connection": {
            "name": "@parameters('$connections')['${var.key_vault_names[count.index]}']['connectionId']"
      }
    },
    "method": "get",
    "path": "/secrets"
  },
  "runAfter": {}
}
BODY

  depends_on = [azurerm_logic_app_trigger_custom.Recurrence_trigger]

}

resource "azurerm_logic_app_action_custom" "foreach_loop" {
  count        = length(var.for_each_name)
  name         = var.for_each_name[count.index]
  logic_app_id = azurerm_logic_app_workflow.logicapp.id

  body = <<BODY
    {
      "type": "Foreach",
      "foreach": "@body('${var.keyvault_action_name[count.index]}')?['value']",
      "actions": {
        "${var.expiry_date[count.index]}": {
          "type": "Compose",
          "inputs": "@convertTimeZone(outputs('${var.secret_list[count.index]}')?['validityEndTime'],'UTC','India Standard Time','yyyy-MM-dd')\n ",
          "runAfter": {
            "${var.secret_list[count.index]}": [
              "Succeeded"
            ]
          }
        },
        "${var.current_date[count.index]}": {
          "type": "Compose",
          "inputs": "@convertFromUtc(formatDateTime(utcNow()),'India Standard Time','yyyy-MM-dd')\n ",
          "runAfter": {
            "${var.expiry_date[count.index]}": [
              "Succeeded"
            ]
          }
        },
        "${var.secret_near_expiry[count.index]}": {
          "type": "Compose",
          "inputs": "@formatDateTime(subtractFromTime(outputs('${var.expiry_date[count.index]}'),30,'Day'),'yyyy-MM-dd')\n ",
          "runAfter": {
            "${var.current_date[count.index]}": [
              "Succeeded"
            ]
          }
        },
        "${var.Condition[count.index]}": {
          "type": "If",
          "expression": {
            "and": [
              {
                "greaterOrEquals": [
                  "@outputs('${var.current_date[count.index]}')",
                  "@outputs('${var.secret_near_expiry[count.index]}')"
                ]
              }
            ]
          },
          "actions": {
            "${var.Send_email[count.index]}": {
              "type": "ApiConnection",
              "inputs": {
                "host": {
                  "connection": {
                    "name": "@parameters('$connections')['acsemail']['connectionId']"
                  }
                },
                "method": "post",
                "body": {
                  "senderAddress": "${var.sender_mail_id}",
                  "recipients": {
                    "to": [
                      {
                        "address": "${var.reciver_email_ids[count.index]}"
                      }
                    ]
                  },
                  "content": {
                    "subject": "test mail",
                    "html": "<p class=\"editor-paragraph\">Hello this is a new test mail from ${var.vault_name[count.index]}</p>"
                  },
                  "importance": "High"
                },
                "path": "/emails:sendGAVersion",
                "queries": {
                  "api-version": "2023-03-31"
                }
              }
            },
            "${var.Send_Data[count.index]}": {
              "type": "ApiConnection",
              "inputs": {
                "host": {
                  "connection": {
                    "name": "@parameters('$connections')['azureloganalyticsdatacollector']['connectionId']"
                  }
                },
                "method": "post",
                "body": "{\n\"Secret Name\":\"@{outputs('${var.secret_list[count.index]}')?['name']}\",\n\"Expiry date\":\"@{outputs('${var.expiry_date[count.index]}')}\",\n\"Key Vault Name\":\"${var.keyvault_action_name[count.index]}\"\n}",
                "headers": {
                  "Log-Type": "customworklog"
                },
                "path": "/api/logs"
              },
              "runAfter": {
                "${var.Send_email[count.index]}": [
                  "Succeeded"
                ]
              }
            }
          },
          "else": {
            "actions": {}
          },
          "runAfter": {
            "${var.secret_near_expiry[count.index]}": [
              "Succeeded"
            ]
          }
        },
        "${var.secret_list[count.index]}": {
          "type": "Compose",
          "inputs": "@items('${var.for_each_name[count.index]}')"
        }
      },
      "runAfter": {
        "${var.keyvault_action_name[count.index]}": [
          "Succeeded"
        ]
      }
    }
    
    BODY

  depends_on = [azurerm_logic_app_action_custom.keyvault_action]

}