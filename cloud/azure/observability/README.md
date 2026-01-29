<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_action_group.oncall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cpu_threshold_critical"></a> [cpu\_threshold\_critical](#input\_cpu\_threshold\_critical) | CPU percentage threshold for critical alerts | `number` | `95` | no |
| <a name="input_cpu_threshold_warning"></a> [cpu\_threshold\_warning](#input\_cpu\_threshold\_warning) | CPU percentage threshold for warning alerts | `number` | `80` | no |
| <a name="input_disk_threshold_critical"></a> [disk\_threshold\_critical](#input\_disk\_threshold\_critical) | Disk percentage threshold for critical alerts | `number` | `95` | no |
| <a name="input_disk_threshold_warning"></a> [disk\_threshold\_warning](#input\_disk\_threshold\_warning) | Disk percentage threshold for warning alerts | `number` | `85` | no |
| <a name="input_enable_alerts"></a> [enable\_alerts](#input\_enable\_alerts) | Enable alert rules (typically disabled for dev) | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, stg, prd) | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics Workspace ID | `string` | `""` | no |
| <a name="input_memory_threshold_critical"></a> [memory\_threshold\_critical](#input\_memory\_threshold\_critical) | Memory percentage threshold for critical alerts | `number` | `95` | no |
| <a name="input_memory_threshold_warning"></a> [memory\_threshold\_warning](#input\_memory\_threshold\_warning) | Memory percentage threshold for warning alerts | `number` | `85` | no |
| <a name="input_oncall_email"></a> [oncall\_email](#input\_oncall\_email) | On-call email address for alert notifications | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group name | `string` | n/a | yes |
| <a name="input_vm_id"></a> [vm\_id](#input\_vm\_id) | VM resource ID for alerts | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_action_group_id"></a> [action\_group\_id](#output\_action\_group\_id) | Action Group ID for oncall notifications |
| <a name="output_action_group_name"></a> [action\_group\_name](#output\_action\_group\_name) | Action Group name |
| <a name="output_vm_alert_ids"></a> [vm\_alert\_ids](#output\_vm\_alert\_ids) | Map of VM alert rule IDs |
<!-- END_TF_DOCS -->