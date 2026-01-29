# Azure Observability Module - Outputs

output "action_group_id" {
  value       = azurerm_monitor_action_group.oncall.id
  description = "Action Group ID for oncall notifications"
}

output "action_group_name" {
  value       = azurerm_monitor_action_group.oncall.name
  description = "Action Group name"
}

output "vm_alert_ids" {
  value = var.vm_id != "" && var.enable_alerts ? {
    cpu_critical    = azurerm_monitor_metric_alert.vm_cpu_critical[0].id
    cpu_warning     = azurerm_monitor_metric_alert.vm_cpu_warning[0].id
    disk_critical   = azurerm_monitor_metric_alert.vm_disk_critical[0].id
    disk_warning    = azurerm_monitor_metric_alert.vm_disk_warning[0].id
  } : {}
  description = "Map of VM alert rule IDs"
}
