# Azure VM + Bastion Infrastructure

> Azure上にVM + Bastion構成を構築するTerraformテンプレート

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.7-blue.svg)](https://www.terraform.io/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 概要

このリポジトリは、Azure上に以下のリソースを構築します:

- **Resource Group** - リソース管理グループ
- **Virtual Network / Subnets** - VM用サブネット + AzureBastionSubnet
- **Network Security Group** - 22/3389をインターネットから遮断、Bastion経由のみ許可
- **Public IP (VM用)** - VMのインターネット通信用
- **Public IP (Bastion用)** - Bastion接続用
- **Linux VM** - Ubuntu 22.04 LTS
- **Azure Bastion** - セキュアな管理アクセス

## アーキテクチャ

```
                    Internet
                        │
            ┌───────────┴───────────┐
            │                       │
     ┌──────▼──────┐        ┌──────▼──────┐
     │  Bastion    │        │  VM Public  │
     │  Public IP  │        │     IP      │
     └──────┬──────┘        └──────┬──────┘
            │                      │
     ┌──────▼──────┐        ┌──────▼──────┐
     │   Azure     │   SSH  │    Linux    │
     │   Bastion   │───────►│     VM      │
     └─────────────┘        └─────────────┘
     AzureBastionSubnet     VM Subnet
        10.0.2.0/27         10.0.1.0/24

                    VNet 10.0.0.0/16
```

## モジュール構成

```
stacks/dev/main.tf
    │
    ├── module "foundation" ← cloud/azure/foundation/
    │     └─ Resource Group, VNet, Key Vault, Log Analytics
    │
    ├── module "network" ← cloud/azure/network/
    │     └─ VM Subnet, AzureBastionSubnet, NAT Gateway, NSG
    │
    └── module "platform" ← cloud/azure/platform/
          └─ VM, NIC, Public IPs, Bastion
```

## クイックスタート

### 1. 前提条件

- Terraform >= 1.7.0
- Azure CLI (認証済み)
- Terraform Cloud アカウント（推奨）
- SSH公開鍵

### 2. Terraform Cloud 設定

1. Terraform Cloud で Organization 作成
2. Workspace 作成 (`infra-dev`, `infra-stg`, `infra-prd`)
3. 各 Workspace の Working Directory を設定:
   - `infra-dev` → `stacks/dev`
   - `infra-stg` → `stacks/stg`
   - `infra-prd` → `stacks/prd`

4. Environment Variables を設定:
   ```
   ARM_CLIENT_ID       = <Service Principal Client ID>
   ARM_CLIENT_SECRET   = <Service Principal Secret> (Sensitive)
   ARM_SUBSCRIPTION_ID = <Azure Subscription ID>
   ARM_TENANT_ID       = <Azure Tenant ID>
   ```

5. Terraform Variables を設定:
   ```
   project        = "demo"
   ssh_public_key = "ssh-rsa AAAA..."
   ```

### 3. backend.tf の更新

```hcl
# stacks/dev/backend.tf
terraform {
  cloud {
    organization = "your-org"  # ← 変更
    workspaces {
      name = "infra-dev"
    }
  }
}
```

### 4. デプロイ

```bash
cd stacks/dev
terraform init
terraform plan
terraform apply
```

## Terraform Cloud Variables

### 必須変数

| 変数名 | 説明 | 例 |
|--------|------|-----|
| `project` | プロジェクト名 | `demo` |
| `ssh_public_key` | SSH公開鍵 | `ssh-rsa AAAA...` |

### オプション変数

| 変数名 | デフォルト | 説明 |
|--------|-----------|------|
| `region` | `japaneast` | Azure リージョン |
| `vm_size` | `Standard_B2s` | VM サイズ |
| `admin_username` | `azureuser` | VM 管理者ユーザー名 |
| `network_cidr` | `10.0.0.0/16` | VNet CIDR |

## Outputs

| 出力名 | 説明 |
|--------|------|
| `resource_group_name` | Resource Group 名 |
| `vnet_id` | VNet ID |
| `vm_public_ip` | VM パブリック IP |
| `vm_private_ip` | VM プライベート IP |
| `bastion_id` | Bastion ID |
| `bastion_name` | Bastion 名 |

## VM 接続方法

### Azure Portal 経由

1. Azure Portal で VM を開く
2. 「接続」→「Bastion」を選択
3. ユーザー名と SSH 秘密鍵を入力
4. 「接続」をクリック

### Azure CLI 経由

```bash
az network bastion ssh \
  --name bas-demo-dev \
  --resource-group rg-demo-dev \
  --target-resource-id /subscriptions/.../virtualMachines/vm-demo-dev \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ~/.ssh/id_rsa
```

## セキュリティ設計

### NSG ルール

| 方向 | ポート | ソース | 許可/拒否 |
|------|--------|--------|----------|
| Inbound | 22 | AzureBastionSubnet | Allow |
| Inbound | 22 | Internet | **Deny** |
| Inbound | 3389 | Internet | **Deny** |

- VM への SSH/RDP はインターネットから直接アクセス不可
- Bastion 経由のみ管理アクセス可能
- VM は Public IP を持つがインバウンドは制限

## ディレクトリ構成

```
.
├── cloud/azure/
│   ├── foundation/     # RG, VNet, Key Vault, Log Analytics
│   ├── network/        # Subnets, NAT Gateway, NSG
│   └── platform/       # VM, Bastion, Public IPs
├── stacks/
│   ├── dev/            # 開発環境
│   ├── stg/            # ステージング環境
│   └── prd/            # 本番環境
└── .claude/rules/      # Claude Code 設定
```

## License

MIT License - see [LICENSE](LICENSE) for details.
