# Azure VM + Bastion Infrastructure

> Azure上にセキュアなVM + Bastion構成を構築するTerraformテンプレート

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.7-blue.svg)](https://www.terraform.io/)
[![Security Scan](https://github.com/innonynet/sample/actions/workflows/security-scan.yml/badge.svg)](https://github.com/innonynet/sample/actions/workflows/security-scan.yml)
[![Policy Check](https://github.com/innonynet/sample/actions/workflows/policy-check.yml/badge.svg)](https://github.com/innonynet/sample/actions/workflows/policy-check.yml)
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
- **Azure Monitor Alerts** - 監視アラート（オプション）

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
    ├── module "platform" ← cloud/azure/platform/
    │     └─ VM, NIC, Bastion, Public IP (Bastion用)
    │
    └── module "observability" ← cloud/azure/observability/ (optional)
          └─ Action Groups, Metric Alerts
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
   oncall_email   = "alerts@example.com"  # Optional
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
| `enable_observability` | `true` | 監視モジュールを有効化 |
| `oncall_email` | `""` | アラート通知先メール |

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

## CI/CD パイプライン

### GitHub Actions ワークフロー

| ワークフロー | トリガー | 内容 |
|-------------|---------|------|
| **Security Scan** | Push, PR | TFLint + Trivy によるセキュリティスキャン |
| **Policy Check** | PR | OPA/Conftest によるポリシーチェック |
| **Drift Detection** | 毎日 09:00 JST | インフラのドリフト検知 |
| **Supply Chain** | Push, PR | SBOM生成、成果物署名、SLSA Provenance |
| **Documentation** | Push | terraform-docs による自動ドキュメント生成 |

### セキュリティスキャン

- **TFLint**: Terraform ベストプラクティス、Azure ルールセット
- **Trivy**: IaC 脆弱性スキャン（HIGH/CRITICAL でブロック）

結果は GitHub Security タブで確認可能。

### ポリシーチェック

PR時に以下のポリシーをチェック:

- **Public IP制限**: Bastion/NAT Gateway以外のPublic IP禁止
- **必須タグ強制**: Environment, Project, ManagedBy タグ必須
- **VM SKU制限**: 許可されたSKUのみ使用可能
- **ストレージ暗号化**: HTTPS必須、TLS 1.2必須

### ドリフト検知

- 毎日自動実行
- ドリフト検知時は GitHub Issue を自動作成
- 手動実行も可能（Actions → Drift Detection → Run workflow）

### サプライチェーンセキュリティ

- **SBOM生成**: CycloneDX/SPDX形式でTerraform依存関係を記録
- **成果物署名**: Sigstore Cosign（キーレス）で署名
- **SLSA Provenance**: Level 2 Provenance生成

## Policy as Code

### OPA/Conftest ポリシー

`policies/opa/terraform/` に配置:

| ポリシー | 説明 |
|---------|------|
| `public_ip.rego` | Public IP制限 |
| `mandatory_tags.rego` | 必須タグ強制 |
| `vm_sku.rego` | VM SKU制限 |
| `storage_encryption.rego` | ストレージ暗号化強制 |

### Azure Policy

`policies/azure/definitions/` にJSON定義:

- `deny-public-ip.json`
- `require-tags.json`
- `allowed-vm-skus.json`
- `require-storage-encryption.json`

`cloud/azure/governance/` モジュールでデプロイ可能。

## Observability/SRE

### アラート

`cloud/azure/observability/` モジュールで以下のアラートを設定:

| アラート | 閾値 | Severity |
|---------|------|----------|
| VM CPU Critical | > 95% | Critical |
| VM CPU Warning | > 80% | Warning |
| VM Disk Critical | > 95% | Critical |
| VM Disk Warning | > 85% | Warning |
| VM Availability | < 100% | Critical |

### SLO定義

- [VM Availability SLO](docs/slo/vm-availability.md) - 99.9% (Production)
- [Bastion Availability SLO](docs/slo/bastion-availability.md) - 99.5% (Production)

### Runbooks

- [VM高CPU対応](docs/runbooks/vm-high-cpu.md)
- [VMディスク満杯対応](docs/runbooks/vm-disk-full.md)
- [Bastion接続障害対応](docs/runbooks/bastion-connection-fail.md)
- [ドリフト検知対応](docs/runbooks/drift-detected.md)

### インシデント対応

- [オンコールガイド](docs/incident-response/on-call-guide.md)
- [エスカレーションマトリクス](docs/incident-response/escalation-matrix.md)
- [ポストモーテムテンプレート](docs/incident-response/postmortem-template.md)

## Developer Experience

### 新環境作成

```bash
./scripts/new-stack.sh <env_name> [options]

# 例:
./scripts/new-stack.sh test
./scripts/new-stack.sh sandbox --project myproject --region westus2
```

詳細: [新環境作成ガイド](docs/guides/new-environment.md)

### 新モジュール作成

```bash
./scripts/new-module.sh <module_name>

# 例:
./scripts/new-module.sh storage
```

詳細: [新モジュール作成ガイド](docs/guides/new-module.md)

### ドキュメント生成

```bash
./scripts/docs-generate.sh [module_path]
```

または、PRマージ時に自動生成。

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

詳細: [セキュリティチェックリスト](docs/guides/security-checklist.md)

## ディレクトリ構成

```
.
├── .github/workflows/
│   ├── drift-detection.yml   # ドリフト検知
│   ├── security-scan.yml     # セキュリティスキャン
│   ├── policy-check.yml      # ポリシーチェック
│   ├── supply-chain.yml      # サプライチェーンセキュリティ
│   └── docs.yml              # ドキュメント生成
├── cloud/azure/
│   ├── foundation/           # RG, VNet, Key Vault, Log Analytics
│   ├── network/              # Subnets, NAT Gateway, NSG
│   ├── platform/             # VM, Bastion
│   ├── governance/           # Azure Policy
│   └── observability/        # Alerts, Action Groups
├── policies/
│   ├── opa/terraform/        # OPA/Conftest ポリシー
│   ├── azure/definitions/    # Azure Policy JSON定義
│   └── lockfile/             # ロックファイル検証
├── stacks/
│   ├── dev/                  # 開発環境
│   ├── stg/                  # ステージング環境
│   └── prd/                  # 本番環境
├── templates/
│   └── stack/                # 新環境テンプレート
├── scripts/
│   ├── new-stack.sh          # 新環境作成
│   ├── new-module.sh         # 新モジュール作成
│   └── docs-generate.sh      # ドキュメント生成
├── docs/
│   ├── slo/                  # SLO定義
│   ├── runbooks/             # 運用手順書
│   ├── incident-response/    # インシデント対応
│   ├── guides/               # ガイド
│   └── adr/                  # ADR
├── .tflint.hcl               # TFLint 設定
├── .trivyignore              # Trivy 除外設定
└── .claude/rules/            # Claude Code 設定
```

## Architecture Decision Records (ADR)

- [ADR 0001: Terraform Cloud使用](docs/adr/0001-use-terraform-cloud.md)
- [ADR 0002: Bastion経由アクセス](docs/adr/0002-bastion-only-access.md)
- [ADR 0003: Policy as Code](docs/adr/0003-policy-as-code.md)

## License

MIT License - see [LICENSE](LICENSE) for details.
