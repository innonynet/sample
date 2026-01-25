# アーキテクチャ解説

## 設計思想

### 1. 責務分離

```
cloud/          # クラウド固有の実装
  ├── aws/
  ├── azure/
  └── gcp/
      ├── foundation/  # 基盤 (VPC, IAM, KMS)
      ├── network/     # ネットワーク (Subnet, NAT, LB)
      └── platform/    # プラットフォーム (K8s, DB, Cache)

stacks/         # 環境別エントリーポイント
  ├── dev/
  ├── stg/
  └── prd/
```

**理由:**
- クラウド固有のコードを分離し、変更影響範囲を限定
- レイヤー分離により、blast radius（影響範囲）を最小化
- 環境差分はtfvarsのみで管理

### 2. State分離戦略

```
State分離単位: 環境 × レイヤー

例:
- dev-foundation
- dev-network
- dev-platform
- stg-foundation
- ...
```

**メリット:**
- 並列apply可能
- 障害時の影響範囲限定
- 権限の最小化が容易

### 3. 統一インターフェース

各クラウドモジュールは同じ変数名・出力名を使用:

```hcl
# 入力 (全クラウド共通)
variable "environment" { ... }
variable "project" { ... }
variable "network_cidr" { ... }

# 出力 (全クラウド共通)
output "vpc_id" { ... }      # AWS: VPC, Azure: VNet, GCP: VPC
output "vpc_cidr" { ... }
```

## OIDC認証設計

### AWS

```
GitHub Actions
    │
    │ OIDC Token
    ▼
AWS IAM Identity Provider
    │
    │ AssumeRoleWithWebIdentity
    ▼
IAM Role (環境別)
    │
    │ Temporary Credentials
    ▼
Terraform Apply
```

**IAM Role設定例:**

```hcl
resource "aws_iam_role" "github_actions" {
  name = "github-actions-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:YOUR_ORG/infra-template:environment:${var.environment}"
        }
      }
    }]
  })
}
```

### Azure

```
GitHub Actions
    │
    │ OIDC Token
    ▼
Azure AD Federated Credential
    │
    │ Service Principal
    ▼
Terraform Apply
```

### GCP

```
GitHub Actions
    │
    │ OIDC Token
    ▼
Workload Identity Federation
    │
    │ Service Account Impersonation
    ▼
Terraform Apply
```

## 環境昇格フロー

```
                    ┌─────────────┐
                    │   開発者    │
                    └──────┬──────┘
                           │ PR作成
                           ▼
┌──────────────────────────────────────────────────┐
│  PR Check                                        │
│  ├── Lint (TFLint)                              │
│  ├── Security Scan (tfsec, Trivy)               │
│  └── Plan (dev)                                 │
└──────────────────────────────────────────────────┘
                           │ レビュー & マージ
                           ▼
┌──────────────────────────────────────────────────┐
│  Deploy dev                                      │
│  └── Apply (自動)                               │
└──────────────────────────────────────────────────┘
                           │ 動作確認OK
                           ▼
┌──────────────────────────────────────────────────┐
│  Deploy stg                                      │
│  └── Apply (自動)                               │
└──────────────────────────────────────────────────┘
                           │ 動作確認OK
                           ▼
┌──────────────────────────────────────────────────┐
│  Deploy prd                                      │
│  ├── Plan                                       │
│  ├── 手動承認 (Required Reviewers)              │
│  └── Apply                                      │
└──────────────────────────────────────────────────┘
```

## 監査・追跡

### 誰が・いつ・何をapplyしたか

1. **GitHub PR履歴**: コード変更の承認者・日時
2. **GitHub Actions Logs**: 実行者・コミットSHA・タイムスタンプ
3. **Terraform Cloud Audit Log**: Run履歴・状態変更
4. **クラウド監査ログ**: CloudTrail / Activity Log / Audit Log

### 推奨設定

```hcl
# CloudTrail有効化 (AWS)
resource "aws_cloudtrail" "main" {
  name           = "terraform-audit"
  s3_bucket_name = aws_s3_bucket.audit_logs.id

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }
}
```

## 破壊防止策

### 1. prevent_destroy

```hcl
resource "aws_db_instance" "main" {
  # ...

  lifecycle {
    prevent_destroy = true
  }
}
```

### 2. 削除保護

```hcl
# RDS
deletion_protection = true

# S3
force_destroy = false

# EKS
# deletion window for KMS keys
```

### 3. ワークフローでの制限

- `terraform destroy` は専用ワークフローでのみ実行可能
- 手動承認必須
- 確認入力必須

## ディレクトリ詳細

```
infra-template/
├── cloud/                    # クラウド別実装
│   ├── aws/
│   │   ├── foundation/      # VPC, IAM, KMS
│   │   ├── network/         # Subnet, NAT, Route
│   │   └── platform/        # EKS, RDS, ElastiCache
│   ├── azure/
│   │   ├── foundation/      # Resource Group, VNet, KeyVault
│   │   ├── network/         # Subnet, NAT Gateway
│   │   └── platform/        # AKS, Azure SQL
│   └── gcp/
│       ├── foundation/      # Project, VPC, KMS
│       ├── network/         # Subnet, Cloud NAT
│       └── platform/        # GKE, Cloud SQL
│
├── modules/                  # クラウド非依存の共通モジュール
│   ├── naming/              # 命名規則
│   └── tagging/             # タグ/ラベル
│
├── stacks/                   # 環境別エントリーポイント
│   ├── dev/
│   ├── stg/
│   └── prd/
│
├── policies/                 # Policy as Code
│   ├── sentinel/            # Terraform Cloud用
│   └── opa/                 # Conftest用
│
└── scripts/                  # ユーティリティスクリプト
```
