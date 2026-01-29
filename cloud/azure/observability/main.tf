# Azure Observability Module
# Creates Azure Monitor alerts and action groups

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# =============================================================================
# Local Variables
# =============================================================================

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "terraform"
  }

  # Alert severity mapping
  severity_map = {
    critical = 0
    error    = 1
    warning  = 2
    info     = 3
    verbose  = 4
  }
}

# =============================================================================
# Action Group (Email Notification)
# =============================================================================

resource "azurerm_monitor_action_group" "oncall" {
  name                = "ag-${var.project}-${var.environment}-oncall"
  resource_group_name = var.resource_group_name
  short_name          = "oncall"

  email_receiver {
    name                    = "oncall-email"
    email_address           = var.oncall_email
    use_common_alert_schema = true
  }

  tags = local.common_tags
}
