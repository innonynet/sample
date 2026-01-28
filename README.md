# Azure VM + Bastion Infrastructure

> Azure上にセキュアなVM + Bastion構成を構築するTerraformテンプレート

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.7-blue.svg)](https://www.terraform.io/)
[![Security Scan](https://github.com/innonynet/sample/actions/workflows/security-scan.yml/badge.svg)](https://github.com/innonynet/sample/actions/workflows/security-scan.yml)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 概要

このリポジトリは、Azure上に以下のリソースを構築します:

- **Resource Group** - リソース管理グループ
- **Virtual Network / Subnets** - VM用サブネット + AzureBastionSubnet
- **Network Security Group** - 22/3389をインターネットから遮断、Bastion経由のみ許可
- **NAT Gateway** - VMのアウトバウンド通信用（固定IP）
- **Public IP (Bastion用)** - Bastion接続用
- **Linux VM** - Ubuntu 22.04 LTS（Private IPのみ）
- **Azure Bastion** - セキュアな管理アクセス
- **Key Vault** - シークレット管理
- **Log Analytics** - ログ収集

## アーキテクチャ

```
                         Internet
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              │              │
        ┌──────────┐         │              │
        │ Bastion  │         │              │
        │Public IP │         │              │
        └────┬─────┘         │              │
             │               │              │
             ▼               │              ▼
        ┌──────────┐         │        ┌──────────┐
        │  Bastion │         │        │   NAT    │
        └────┬─────┘         │        │ Gateway  │
             │               │        └────▲─────┘
             │ SSH           │             │
             ▼               │             │
        ┌──────────┐         │             │
        │    VM    │─────────────Outbound──┘
        │(Private) │
        └──────────┘

              VNet 10.0.0.0/16
```

**通信フロー:**
- **Inbound (管理):** Internet → Bastion Public IP → Bastion → VM
- **Outbound:** VM → NAT Gateway → Internet

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
          └─ VM, NIC, Bastion, Public IP (Bastion用)
```

## クイックスタート

### 1. 前提条件

- Terraform >= 1.7.0
- Azure CLI (認証済み)
- Terraform Cloud アカウント
- SSH公開鍵（RSA形式）

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

### 4. GitHub Secrets の設定

```
TF_API_TOKEN = <Terraform Cloud API Token>
```

### 5. デプロイ

VCS連携の場合、`main`ブランチへのpushで自動デプロイ。

手動の場合:
```bash
cd stacks/dev
terraform init
terraform plan
terraform apply
```

## Terraform Variables

### 必須変数

| 変数名 | 説明 | 例 |
|--------|------|-----|
| `project` | プロジェクト名 | `demo` |
| `ssh_public_key` | SSH公開鍵（RSA形式） | `ssh-rsa AAAA...` |

### オプション変数

| 変数名 | デフォルト | 説明 |
|--------|-----------|------|
| `region` | `japaneast` | Azure リージョン |
| `vm_size` | `Standard_D2s_v3` | VM サイズ |
| `admin_username` | `azureuser` | VM 管理者ユーザー名 |
| `network_cidr` | `10.0.0.0/16` | VNet CIDR |

## Outputs

| 出力名 | 説明 |
|--------|------|
| `resource_group_name` | Resource Group 名 |
| `vnet_id` | VNet ID |
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
  --target-resource-id /subscriptions/<subscription-id>/resourceGroups/rg-demo-dev/providers/Microsoft.Compute/virtualMachines/vm-demo-dev \
  --auth-type ssh-key \
  --username azureuser \
  --ssh-key ~/.ssh/id_rsa
```

## CI/CD

### GitHub Actions ワークフロー

| ワークフロー | トリガー | 内容 |
|-------------|---------|------|
| **Security Scan** | Push, PR | TFLint + Trivy によるセキュリティスキャン |
| **Drift Detection** | 毎日 09:00 JST | インフラのドリフト検知 |

### セキュリティスキャン

- **TFLint**: Terraform ベストプラクティス、Azure ルールセット
- **Trivy**: IaC 脆弱性スキャン（HIGH/CRITICAL でブロック）

結果は GitHub Security タブで確認可能。

### ドリフト検知

- 毎日自動実行
- ドリフト検知時は GitHub Issue を自動作成
- 手動実行も可能（Actions → Drift Detection → Run workflow）

## セキュリティ設計

### NSG ルール

| 方向 | ポート | ソース | 許可/拒否 |
|------|--------|--------|----------|
| Inbound | 22 | AzureBastionSubnet | Allow |
| Inbound | 22 | Internet | **Deny** |
| Inbound | 3389 | Internet | **Deny** |

### セキュリティポイント

- VM は Private IP のみ（インターネットから直接アクセス不可）
- 管理アクセスは Bastion 経由のみ
- アウトバウンド通信は NAT Gateway 経由（固定IP）
- Key Vault はネットワーク制限あり（Azure Services のみ）

## ディレクトリ構成

```
.
├── .github/workflows/
│   ├── drift-detection.yml  # ドリフト検知
│   └── security-scan.yml    # セキュリティスキャン
├── cloud/azure/
│   ├── foundation/          # RG, VNet, Key Vault, Log Analytics
│   ├── network/             # Subnets, NAT Gateway, NSG
│   └── platform/            # VM, Bastion
├── stacks/
│   ├── dev/                 # 開発環境
│   ├── stg/                 # ステージング環境
│   └── prd/                 # 本番環境
├── .tflint.hcl              # TFLint 設定
├── .trivyignore             # Trivy 除外設定
└── .claude/rules/           # Claude Code 設定
```

## License

MIT License - see [LICENSE](LICENSE) for details.
