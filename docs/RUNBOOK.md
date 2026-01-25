# 運用手順書 (Runbook)

## 日常運用

### PRワークフロー

1. Feature branchを作成
2. コード変更
3. PR作成
4. 自動でPlan実行・セキュリティスキャン
5. レビュー・承認
6. マージ → 自動デプロイ

### 環境へのデプロイ

#### dev環境
- mainへのマージで自動デプロイ
- 承認不要

#### stg環境
- mainへのマージで自動デプロイ
- devでの動作確認後

#### prd環境
- 手動でワークフロー実行
- Required Reviewersによる承認必須
- 確認入力: `deploy-prd`

```bash
# GitHub CLI でワークフロー実行
gh workflow run deploy-prd.yml -f confirm=deploy-prd
```

## トラブルシューティング

### Terraform Init失敗

#### Backend接続エラー

```
Error: Failed to get existing workspaces: S3 bucket does not exist
```

**対処:**
1. Backend用S3バケットが存在するか確認
2. IAM権限を確認
3. リージョン設定を確認

```bash
aws s3 ls s3://your-org-terraform-state
```

#### Terraform Cloud認証エラー

```
Error: Required token could not be found
```

**対処:**
```bash
terraform login
# または
export TF_TOKEN_app_terraform_io="your-token"
```

### Terraform Plan失敗

#### Provider認証エラー

```
Error: error configuring Terraform AWS Provider
```

**対処:**
1. OIDC設定を確認
2. IAM Roleの信頼関係を確認
3. GitHub Secretsを確認

```bash
# ローカルで認証テスト
aws sts get-caller-identity
```

#### State Lock

```
Error: Error acquiring the state lock
```

**対処:**
1. 他のapplyが実行中でないか確認
2. Lock解除（緊急時のみ）

```bash
terraform force-unlock LOCK_ID
```

### Terraform Apply失敗

#### リソース依存関係エラー

```
Error: Error creating X: DependencyViolation
```

**対処:**
1. 依存リソースが存在するか確認
2. `terraform plan`で依存関係を確認
3. 必要なら`depends_on`を追加

#### 権限エラー

```
Error: AccessDenied: User is not authorized
```

**対処:**
1. IAM Role/Policyを確認
2. リソースポリシーを確認
3. SCP（Organizations使用時）を確認

### Drift検知

#### Driftが検出された場合

1. **通知確認**: Slack通知を確認
2. **原因特定**: 手動変更か、別プロセスか
3. **対応判断**:
   - Terraformに合わせる → PR作成してapply
   - 手動変更を取り込む → コードを更新してapply

```bash
# 現在のstateを確認
terraform show

# 特定リソースの詳細
terraform state show aws_instance.example
```

### セキュリティスキャン失敗

#### tfsec警告

```
HIGH: S3 bucket has logging disabled
```

**対処:**
1. 警告内容を確認
2. 修正が必要な場合はコード修正
3. 例外が妥当な場合は`.trivyignore`に追加

```hcl
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "temp" {
  # 一時的なバケットでログ不要
}
```

## 緊急対応

### 本番環境の緊急修正

1. **Hotfix branchを作成**
```bash
git checkout -b hotfix/critical-fix main
```

2. **最小限の修正をコミット**

3. **PRを作成（緊急フラグ付き）**
   - タイトルに`[URGENT]`を付与
   - 影響範囲を明記

4. **迅速なレビュー・承認**

5. **デプロイ・監視**

### ロールバック

#### Terraform Cloudの場合

1. TFC UIで前回の成功Runを確認
2. "Queue plan" で前回のstateに戻す

#### 自前Backendの場合

```bash
# Stateのバージョン一覧
aws s3api list-object-versions \
  --bucket your-org-terraform-state \
  --prefix prd/terraform.tfstate

# 特定バージョンに戻す
aws s3api get-object \
  --bucket your-org-terraform-state \
  --key prd/terraform.tfstate \
  --version-id VERSION_ID \
  terraform.tfstate.backup

# 確認後に復元
aws s3 cp terraform.tfstate.backup \
  s3://your-org-terraform-state/prd/terraform.tfstate
```

### 環境削除（非推奨）

**警告**: 本番環境の削除は非常に危険です。

```bash
# 1. 確認ワークフローを実行
gh workflow run destroy.yml -f environment=dev -f confirm=destroy-dev

# 2. 手動承認（prdの場合は複数人）

# 3. 削除実行・確認
```

## 定期作業

### 週次

- [ ] Dependabot PRのレビュー・マージ
- [ ] セキュリティアラートの確認

### 月次

- [ ] Terraformバージョン更新の検討
- [ ] Providerバージョン更新の検討
- [ ] IAM権限の棚卸し

### 四半期

- [ ] セキュリティポリシーのレビュー
- [ ] DR訓練（State復元）
- [ ] アクセス権限の棚卸し

## 連絡先

| 状況 | 連絡先 |
|------|--------|
| 通常の質問 | #platform-team (Slack) |
| 緊急対応 | @platform-oncall (Slack) |
| セキュリティインシデント | security@example.com |
