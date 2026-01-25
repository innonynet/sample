# クイックスタート詳細ガイド

このガイドでは、テンプレートを使って最短でインフラをデプロイする手順を説明します。

## 前提条件

- [ ] Terraform >= 1.7.0 インストール済み
- [ ] 選択したクラウドのCLI設定済み (aws-cli / az-cli / gcloud)
- [ ] GitHub リポジトリ作成済み
- [ ] 必要な権限を持つクラウドアカウント

## Step 1: リポジトリ準備

```bash
# テンプレートをフォーク後、クローン
git clone https://github.com/YOUR_ORG/infra-template.git
cd infra-template

# 使わないクラウドを削除 (例: AWSのみ使用)
rm -rf cloud/azure cloud/gcp
```

## Step 2: 変数設定

### terraform.tfvars を編集

```bash
# stacks/dev/terraform.tfvars
cp stacks/dev/terraform.tfvars.example stacks/dev/terraform.tfvars
```

```hcl
# stacks/dev/terraform.tfvars
environment  = "dev"
project      = "myproject"
region       = "ap-northeast-1"  # AWS
# region     = "japaneast"       # Azure
# region     = "asia-northeast1" # GCP

network_cidr = "10.0.0.0/16"

tags = {
  Owner   = "platform-team"
  CostCenter = "engineering"
}
```

## Step 3: Backend設定

### オプションA: Terraform Cloud

1. [Terraform Cloud](https://app.terraform.io/) でWorkspace作成
2. backend.tf を編集:

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

3. 認証:

```bash
terraform login
```

### オプションB: 自前Backend (AWS S3)

1. Backendリソース作成:

```bash
./scripts/setup-backend-aws.sh
```

2. backend.tf を編集:

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

## Step 4: ローカルで動作確認

```bash
cd stacks/dev

# 初期化
terraform init

# フォーマットチェック
terraform fmt -check -recursive

# 検証
terraform validate

# Plan
terraform plan
```

## Step 5: GitHub設定

### OIDC設定 (AWS例)

1. AWS側でOIDC Provider作成:

```bash
# CloudFormationまたはTerraformで作成
# 詳細は docs/ARCHITECTURE.md 参照
```

2. GitHub Secretsに設定:

```
AWS_ROLE_ARN_DEV: arn:aws:iam::111111111111:role/github-actions-dev
```

### Environments設定

1. Settings > Environments
2. 以下を作成:
   - `dev`: 制限なし
   - `stg`: main branch only
   - `prd`: main branch only + Required reviewers

### Branch Protection設定

1. Settings > Branches > Add rule
2. Branch name pattern: `main`
3. 以下を有効化:
   - Require pull request
   - Require status checks
   - Require Code Owners review

## Step 6: 初回デプロイ

```bash
# ブランチ作成
git checkout -b feature/initial-setup

# 変更をコミット
git add .
git commit -m "feat: initial infrastructure setup"

# プッシュ
git push origin feature/initial-setup

# PRを作成 → Plan実行を確認 → マージ → 自動デプロイ
```

## Step 7: stg/prd環境の設定

dev環境が動作したら、同様の手順でstg/prdを設定:

```bash
# stg
cp stacks/dev/terraform.tfvars stacks/stg/terraform.tfvars
# environment = "stg" に変更

# prd
cp stacks/dev/terraform.tfvars stacks/prd/terraform.tfvars
# environment = "prd" に変更
```

## 次のステップ

- [ ] [セキュリティ設定](SECURITY.md) を確認
- [ ] [アーキテクチャ](ARCHITECTURE.md) を理解
- [ ] チーム用にCODEOWNERSを更新
- [ ] Slack通知を設定 (Drift検知用)
