# セキュリティガイド

## 概要

このテンプレートでは、多層防御アプローチでインフラのセキュリティを確保します。

## 認証・認可

### OIDC認証（推奨）

長期キーを使わず、短期トークンでクラウドに認証:

```yaml
# GitHub Actions での OIDC 設定
permissions:
  id-token: write
  contents: read
```

**メリット:**
- シークレットローテーション不要
- 短期トークン（1時間以内で失効）
- 監査が容易

### IAM最小権限

各環境のIAMロールは必要最小限の権限のみ付与:

```hcl
# 悪い例: Admin権限
# arn:aws:iam::aws:policy/AdministratorAccess

# 良い例: 必要な権限のみ
resource "aws_iam_role_policy" "terraform" {
  name = "terraform-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "rds:*",
          "eks:*"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion": var.allowed_regions
          }
        }
      }
    ]
  })
}
```

## セキュリティスキャン

### 最小構成（Phase 0-1）

| ツール | 目的 | 実行 |
|--------|------|------|
| **tfsec** | IaC脆弱性検出 | PR時 |
| **Trivy** | IaC + イメージスキャン | PR時 |
| **TFLint** | ベストプラクティス違反検出 | PR時 |
| **Dependabot** | 依存関係の脆弱性 | 週次 |
| **Secret Scanning** | シークレット漏洩検出 | 常時 |

### 拡張構成（Phase 2+）

| ツール | 目的 | 導入時期 |
|--------|------|---------|
| **Checkov** | CIS Benchmark準拠チェック | Phase 2 |
| **Snyk / Grype** | より詳細なSCA | Phase 2 |
| **SBOM** | サプライチェーン可視化 | Phase 2 |
| **OPA / Sentinel** | カスタムポリシー | Phase 2 |
| **KICS** | マルチIaC対応 | Phase 3 |

## Policy as Code

### OPA (Open Policy Agent)

```rego
# policies/opa/deny-public-access.rego
package terraform

# S3パブリックアクセス禁止
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_s3_bucket_public_access_block"
    resource.change.after.block_public_acls == false
    msg := sprintf("S3 bucket %s must block public ACLs", [resource.address])
}

# SSHの0.0.0.0/0禁止
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group_rule"
    resource.change.after.cidr_blocks[_] == "0.0.0.0/0"
    resource.change.after.from_port == 22
    msg := sprintf("Security group %s allows SSH from anywhere", [resource.address])
}

# 暗号化必須
deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_ebs_volume"
    resource.change.after.encrypted == false
    msg := sprintf("EBS volume %s must be encrypted", [resource.address])
}
```

### Sentinel (Terraform Cloud)

```python
# policies/sentinel/require-tags.sentinel
import "tfplan/v2" as tfplan

required_tags = ["Environment", "Project", "Owner", "ManagedBy"]

allResourcesHaveRequiredTags = rule {
    all tfplan.resource_changes as _, rc {
        rc.mode is "managed" and
        rc.change.after.tags is not null and
        all required_tags as tag {
            tag in keys(rc.change.after.tags)
        }
    }
}

main = rule { allResourcesHaveRequiredTags }
```

## シークレット管理

### 絶対にコミットしてはいけないもの

- `.env` ファイル
- `*.tfvars` に含まれるシークレット
- `credentials.json`
- SSH秘密鍵
- APIキー・トークン

### .gitignore設定

```gitignore
# Secrets
*.tfvars
!*.tfvars.example
.env
.env.*
credentials.json
*.pem
*.key
```

### シークレットの正しい管理方法

1. **GitHub Secrets**: CI/CD用
2. **AWS Secrets Manager / Azure Key Vault / GCP Secret Manager**: ランタイム用
3. **Terraform Cloud Variables**: Sensitive変数として設定

## ネットワークセキュリティ

### デフォルト設定

```hcl
# パブリックアクセス禁止
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# デフォルトで暗号化
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}
```

### セキュリティグループルール

```hcl
# 悪い例
cidr_blocks = ["0.0.0.0/0"]

# 良い例
cidr_blocks = [var.vpc_cidr]  # VPC内部のみ
# または
security_groups = [aws_security_group.app.id]  # SG参照
```

## 監査ログ

### 有効化必須

- **AWS**: CloudTrail
- **Azure**: Activity Log
- **GCP**: Audit Log

### ログ保持期間

| 環境 | 推奨保持期間 |
|------|-------------|
| dev | 30日 |
| stg | 90日 |
| prd | 365日以上 |

## インシデント対応

### 漏洩時の対応

1. **即時**: 漏洩した認証情報を無効化
2. **調査**: CloudTrail等で影響範囲を確認
3. **修復**: 新しい認証情報を発行
4. **再発防止**: Secret Scanning有効化確認

### 不正変更検知

- Drift検知ワークフローで毎日チェック
- 検知時はSlack通知
- 意図しない変更は即時調査

## チェックリスト

### 初期設定

- [ ] OIDC認証設定完了
- [ ] IAM最小権限設定
- [ ] Secret Scanning有効化
- [ ] Dependabot有効化
- [ ] Branch Protection設定

### 運用時

- [ ] PR時のセキュリティスキャン確認
- [ ] Drift検知の定期確認
- [ ] 依存関係更新の定期レビュー
- [ ] 監査ログの定期確認
