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
| [azurerm_policy_definition.allowed_vm_skus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |
| [azurerm_policy_definition.deny_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |
| [azurerm_policy_definition.require_storage_encryption](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |
| [azurerm_policy_definition.require_tags](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |
| [azurerm_resource_group_policy_assignment.allowed_vm_skus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.deny_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.require_storage_encryption](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.require_tags](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_public_ip_patterns"></a> [allowed\_public\_ip\_patterns](#input\_allowed\_public\_ip\_patterns) | Allowed name patterns for Public IPs | `list(string)` | <pre>[<br/>  "*bastion*",<br/>  "*nat*"<br/>]</pre> | no |
| <a name="input_allowed_vm_skus"></a> [allowed\_vm\_skus](#input\_allowed\_vm\_skus) | List of allowed VM SKUs | `list(string)` | <pre>[<br/>  "Standard_B1s",<br/>  "Standard_B1ms",<br/>  "Standard_B2s",<br/>  "Standard_B2ms",<br/>  "Standard_D2s_v3",<br/>  "Standard_D2s_v4",<br/>  "Standard_D2s_v5",<br/>  "Standard_D4s_v3",<br/>  "Standard_D4s_v4",<br/>  "Standard_D4s_v5",<br/>  "Standard_D8s_v3",<br/>  "Standard_D8s_v4",<br/>  "Standard_D8s_v5"<br/>]</pre> | no |
| <a name="input_enable_policy_assignments"></a> [enable\_policy\_assignments](#input\_enable\_policy\_assignments) | Enable policy assignments (set to false for policy definition only) | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, stg, prd) | `string` | n/a | yes |
| <a name="input_policy_effect"></a> [policy\_effect](#input\_policy\_effect) | Policy effect (Audit, Deny, or Disabled) | `string` | `"Audit"` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Resource Group ID for policy assignments | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy_assignment_ids"></a> [policy\_assignment\_ids](#output\_policy\_assignment\_ids) | Map of policy assignment IDs |
| <a name="output_policy_definition_ids"></a> [policy\_definition\_ids](#output\_policy\_definition\_ids) | Map of policy definition IDs |
<!-- END_TF_DOCS -->