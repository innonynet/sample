<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_foundation"></a> [foundation](#module\_foundation) | ../../cloud/azure/foundation | n/a |
| <a name="module_network"></a> [network](#module\_network) | ../../cloud/azure/network | n/a |
| <a name="module_observability"></a> [observability](#module\_observability) | ../../cloud/azure/observability | n/a |
| <a name="module_platform"></a> [platform](#module\_platform) | ../../cloud/azure/platform | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Admin username for VM | `string` | `"azureuser"` | no |
| <a name="input_enable_observability"></a> [enable\_observability](#input\_enable\_observability) | Enable observability module (alerts, action groups) | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"dev"` | no |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | Network CIDR block | `string` | `"10.0.0.0/16"` | no |
| <a name="input_oncall_email"></a> [oncall\_email](#input\_oncall\_email) | On-call email address for alert notifications | `string` | `""` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Azure region | `string` | `"japaneast"` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Source repository | `string` | `"your-org/infra-template"` | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key for VM authentication | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags | `map(string)` | `{}` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | VM size | `string` | `"Standard_D2s_v3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_id"></a> [bastion\_id](#output\_bastion\_id) | Bastion host ID |
| <a name="output_bastion_name"></a> [bastion\_name](#output\_bastion\_name) | Bastion host name |
| <a name="output_environment"></a> [environment](#output\_environment) | Environment name |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource Group name |
| <a name="output_vm_private_ip"></a> [vm\_private\_ip](#output\_vm\_private\_ip) | VM private IP address |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | VNet ID |
<!-- END_TF_DOCS -->