# VM Metric Alerts
# CPU, Memory, Disk alerts for Virtual Machines

# =============================================================================
# CPU Alerts
# =============================================================================

resource "azurerm_monitor_metric_alert" "vm_cpu_critical" {
  count = var.vm_id != "" && var.enable_alerts ? 1 : 0

  name                = "alert-${var.project}-${var.environment}-vm-cpu-critical"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Alert when VM CPU exceeds ${var.cpu_threshold_critical}%"
  severity            = local.severity_map.critical
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_threshold_critical
  }

  action {
    action_group_id = azurerm_monitor_action_group.oncall.id
  }

  tags = local.common_tags
}

resource "azurerm_monitor_metric_alert" "vm_cpu_warning" {
  count = var.vm_id != "" && var.enable_alerts ? 1 : 0

  name                = "alert-${var.project}-${var.environment}-vm-cpu-warning"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Alert when VM CPU exceeds ${var.cpu_threshold_warning}%"
  severity            = local.severity_map.warning
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_threshold_warning
  }

  action {
    action_group_id = azurerm_monitor_action_group.oncall.id
  }

  tags = local.common_tags
}

# =============================================================================
# Disk Alerts
# =============================================================================

resource "azurerm_monitor_metric_alert" "vm_disk_critical" {
  count = var.vm_id != "" && var.enable_alerts ? 1 : 0

  name                = "alert-${var.project}-${var.environment}-vm-disk-critical"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Alert when VM disk usage exceeds ${var.disk_threshold_critical}%"
  severity            = local.severity_map.critical
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "OS Disk Bandwidth Consumed Percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.disk_threshold_critical
  }

  action {
    action_group_id = azurerm_monitor_action_group.oncall.id
  }

  tags = local.common_tags
}

resource "azurerm_monitor_metric_alert" "vm_disk_warning" {
  count = var.vm_id != "" && var.enable_alerts ? 1 : 0

  name                = "alert-${var.project}-${var.environment}-vm-disk-warning"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Alert when VM disk usage exceeds ${var.disk_threshold_warning}%"
  severity            = local.severity_map.warning
  frequency           = "PT15M"
  window_size         = "PT1H"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "OS Disk Bandwidth Consumed Percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.disk_threshold_warning
  }

  action {
    action_group_id = azurerm_monitor_action_group.oncall.id
  }

  tags = local.common_tags
}

# =============================================================================
# VM Availability Alert
# =============================================================================

resource "azurerm_monitor_metric_alert" "vm_availability" {
  count = var.vm_id != "" && var.enable_alerts ? 1 : 0

  name                = "alert-${var.project}-${var.environment}-vm-availability"
  resource_group_name = var.resource_group_name
  scopes              = [var.vm_id]
  description         = "Alert when VM availability drops below 100%"
  severity            = local.severity_map.critical
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "VmAvailabilityMetric"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1
  }

  action {
    action_group_id = azurerm_monitor_action_group.oncall.id
  }

  tags = local.common_tags
}
