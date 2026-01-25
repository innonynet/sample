# Infrastructure Template

> マルチクラウド対応 IaC + CI/CD テンプレート (AWS / Azure / GCP)

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.7-blue.svg)](https://www.terraform.io/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 🚀 クイックスタート（5分で始める）

### Step 1: あなたの構成を選ぶ

| 選択項目 | 選択肢 |
|---------|--------|
| クラウド | [ ] AWS / [ ] Azure / [ ] GCP |
| Backend | [ ] Terraform Cloud / [ ] 自前管理 (S3/GCS/Blob) |
| 初期環境 | dev（推奨）→ stg → prd の順で構築 |

### Step 2: リポジトリをフォーク & クローン

```bash
# フォーク後
git clone https://github.com/YOUR_ORG/infra-template.git
cd infra-template
```

### Step 3: 不要なクラウドディレクトリを削除

```bash
# AWSのみ使う場合
rm -rf cloud/azure cloud/gcp

# Azureのみ使う場合
rm -rf cloud/aws cloud/gcp

# GCPのみ使う場合
rm -rf cloud/aws cloud/azure
```

### Step 4: Backend設定

- [Terraform Cloud を使う場合](#terraform-cloud-setup)
- [自前Backend を使う場合](#self-managed-backend)

### Step 5: GitHub設定

- [必須設定チェックリスト](#github-setup)

### Step 6: 初回デプロイ

```bash
# dev環境で動作確認
cd stacks/dev
terraform init
terraform plan

# PRを作成してマージ → 自動デプロイ
```

---

## 📁 使うファイル早見表

| あなたの選択 | 使うディレクトリ | 削除してよいもの |
|-------------|-----------------|-----------------|
| AWS + TFC | `cloud/aws/`, `stacks/`, `policies/sentinel/` | `cloud/azure/`, `cloud/gcp/`, `policies/opa/` |
| AWS + 自前Backend | `cloud/aws/`, `stacks/`, `policies/opa/` | `cloud/azure/`, `cloud/gcp/`, `policies/sentinel/` |
| Azure + TFC | `cloud/azure/`, `stacks/`, `policies/sentinel/` | `cloud/aws/`, `cloud/gcp/`, `policies/opa/` |
| Azure + 自前Backend | `cloud/azure/`, `stacks/`, `policies/opa/` | `cloud/aws/`, `cloud/gcp/`, `policies/sentinel/` |
| GCP + TFC | `cloud/gcp/`, `stacks/`, `policies/sentinel/` | `cloud/aws/`, `cloud/azure/`, `policies/opa/` |
| GCP + 自前Backend | `cloud/gcp/`, `stacks/`, `policies/opa/` | `cloud/aws/`, `cloud/azure/`, `policies/sentinel/` |

---

## 🔧 設定リファレンス

### <a id="terraform-cloud-setup"></a>Terraform Cloud設定

#### 1. Workspace作成

```
Organization: your-org
├── Project: infrastructure
│   ├── Workspace: infra-dev
│   ├── Workspace: infra-stg
│   └── Workspace: infra-prd
```

#### 2. backend.tf を編集

```hcl
# stacks/dev/backend.tf
terraform {
  cloud {
    organization = "your-org"
    workspaces {
      name = "infra-dev"
    }
  }
}
```

#### 3. Workspace設定

| 設定項目 | dev | stg | prd |
|---------|-----|-----|-----|
| Execution Mode | Remote | Remote | Remote |
| Apply Method | Auto apply | Auto apply | **Manual apply** |
| Working Directory | stacks/dev | stacks/stg | stacks/prd |

#### 4. Variables設定

Terraform Cloud UIで以下を設定:
- `TF_VAR_environment`: dev / stg / prd
- `TF_VAR_project`: your-project-name

OIDC連携する場合は [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) を参照。

---

### <a id="self-managed-backend"></a>自前Backend設定

#### AWS (S3 + DynamoDB)

```bash
# Backend用リソース作成
./scripts/setup-backend-aws.sh

# backend.tf を編集
```

```hcl
# stacks/dev/backend.tf
terraform {
  backend "s3" {
    bucket         = "your-org-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

#### Azure (Storage Account)

```hcl
# stacks/dev/backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name       = "tfstate"
    key                  = "dev/terraform.tfstate"
  }
}
```

#### GCP (Cloud Storage)

```hcl
# stacks/dev/backend.tf
terraform {
  backend "gcs" {
    bucket = "your-org-terraform-state"
    prefix = "dev"
  }
}
```

---

### <a id="github-setup"></a>GitHub設定チェックリスト

#### Secrets設定

Settings > Secrets and variables > Actions

**AWS使用時:**
```
AWS_ROLE_ARN_DEV:  arn:aws:iam::111111111111:role/github-actions-dev
AWS_ROLE_ARN_STG:  arn:aws:iam::222222222222:role/github-actions-stg
AWS_ROLE_ARN_PRD:  arn:aws:iam::333333333333:role/github-actions-prd
```

**Azure使用時:**
```
AZURE_CLIENT_ID:          xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
AZURE_TENANT_ID:          xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
AZURE_SUBSCRIPTION_ID_DEV: ...
AZURE_SUBSCRIPTION_ID_STG: ...
AZURE_SUBSCRIPTION_ID_PRD: ...
```

**GCP使用時:**
```
GCP_WORKLOAD_IDENTITY_PROVIDER: projects/xxx/locations/global/workloadIdentityPools/github/providers/github
GCP_SERVICE_ACCOUNT_DEV: github-actions@project-dev.iam.gserviceaccount.com
GCP_SERVICE_ACCOUNT_STG: github-actions@project-stg.iam.gserviceaccount.com
GCP_SERVICE_ACCOUNT_PRD: github-actions@project-prd.iam.gserviceaccount.com
```

**Terraform Cloud使用時:**
```
TF_API_TOKEN: your-terraform-cloud-token
```

#### Environments作成

Settings > Environments

- [ ] `dev` - Deployment branches: All branches
- [ ] `stg` - Deployment branches: main only
- [ ] `prd` - Deployment branches: main only, **Required reviewers: 有効化**

#### Branch Protection

Settings > Branches > Add rule

Branch name pattern: `main`

- [x] Require a pull request before merging
  - [x] Require approvals: 1
  - [x] Require review from Code Owners
- [x] Require status checks to pass
  - Required: `terraform-plan`, `security-scan`, `lint`
- [x] Do not allow bypassing the above settings

---

## 🛡️ セキュリティ

### 最小構成（必須）

| ツール | 用途 | 実行タイミング |
|--------|------|---------------|
| tfsec | IaC脆弱性スキャン | PR時 |
| Trivy | IaC + コンテナスキャン | PR時 |
| TFLint | Terraform Linter | PR時 |
| Dependabot | 依存関係更新 | 週次自動PR |
| Secret Scanning | シークレット検出 | 常時 |

### 拡張構成（推奨）

| ツール | 用途 | 導入フェーズ |
|--------|------|-------------|
| Checkov | 追加IaCルール | Phase 2 |
| Snyk / Grype | SCA強化 | Phase 2 |
| SBOM (CycloneDX) | サプライチェーン | Phase 2 |
| OPA / Sentinel | Policy as Code | Phase 2 |
| KICS | マルチIaC対応 | Phase 3 |

---

## 📋 運用ガイド

### PRワークフロー

```
1. feature branch作成
2. コード変更
3. PR作成 → 自動でPlan実行
4. Plan結果をレビュー
5. 承認 & マージ
6. dev環境に自動デプロイ
```

### 環境昇格フロー

```
dev (自動デプロイ)
    ↓ 動作確認OK
stg (自動デプロイ)
    ↓ 動作確認OK
prd (手動承認 → デプロイ)
```

### Drift検知

- 毎日09:00 JSTに自動実行
- 差分検出時はSlack通知
- 対応: PRを作成して修正、または手動変更を元に戻す

---

## 🆘 トラブルシューティング

→ [docs/RUNBOOK.md](docs/RUNBOOK.md)

## 📚 詳細ドキュメント

- [アーキテクチャ解説](docs/ARCHITECTURE.md)
- [セキュリティガイド](docs/SECURITY.md)
- [クイックスタート詳細](docs/QUICK_START.md)
- [ADR一覧](docs/decisions/)

---

## License

MIT License - see [LICENSE](LICENSE) for details.
