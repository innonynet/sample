# Network Metric Alerts
# Network throughput and connectivity alerts

# =============================================================================
# Network In/Out Alerts
# =============================================================================

resource "azurerm_monitor_metric_alert" "vm_network_in_high" {
  count = var.vm_id != "" && var.enable_alerts ? 1 : 0

  name                = "alert-${var.project}-${var.environment}-vm-network-in-high"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Alert when VM network inbound traffic is unusually high"
  severity            = local.severity_map.warning
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Network In Total"
    aggregation      = "Total"
    operator         = "GreaterThan"
    # 1GB in 15 minutes
    threshold = 1073741824
  }

  action {
    action_group_id = azurerm_monitor_action_group.oncall.id
  }

  tags = local.common_tags
}

resource "azurerm_monitor_metric_alert" "vm_network_out_high" {
  count = var.vm_id != "" && var.enable_alerts ? 1 : 0

  name                = "alert-${var.project}-${var.environment}-vm-network-out-high"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Alert when VM network outbound traffic is unusually high"
  severity            = local.severity_map.warning
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Network Out Total"
    aggregation      = "Total"
    operator         = "GreaterThan"
    # 1GB in 15 minutes
    threshold = 1073741824
  }

  action {
    action_group_id = azurerm_monitor_action_group.oncall.id
  }

  tags = local.common_tags
}
