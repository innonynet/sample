# ADR 001: State分離戦略

## ステータス

採用済み

## コンテキスト

Terraformのstateファイルをどのように分離するかは、以下の点に影響する重要な決定事項です:

- 並列apply可能性
- 障害時の影響範囲
- 権限分離の粒度
- 運用の複雑さ

## 決定

**環境 × レイヤー単位でstateを分離する**

```
stacks/
├── dev/      → state: dev/terraform.tfstate
├── stg/      → state: stg/terraform.tfstate
└── prd/      → state: prd/terraform.tfstate
```

将来的にレイヤー分離が必要な場合:

```
stacks/
├── dev/
│   ├── foundation/  → state: dev/foundation.tfstate
│   ├── network/     → state: dev/network.tfstate
│   └── platform/    → state: dev/platform.tfstate
```

## 理由

### 採用した方式のメリット

1. **blast radius（影響範囲）の限定**
   - あるstateの障害が他環境に影響しない
   - apply失敗時の影響が限定的

2. **並列実行可能**
   - 異なる環境のapplyを同時実行可能
   - CI/CDパイプラインの高速化

3. **権限分離が容易**
   - 環境ごとに異なるIAM権限を適用可能
   - prdへのアクセスをより厳密に制限

4. **運用の柔軟性**
   - 特定環境のみのapplyが容易
   - state操作（import, rm等）の影響が限定的

### 検討した代替案

#### モノリシックstate（不採用）

```
全環境・全リソース → 単一state
```

**不採用理由:**
- 単一障害点になる
- applyに長時間かかる
- 権限分離が困難

#### Workspace分離（部分採用）

```
terraform workspace select dev
```

**部分採用理由:**
- Terraform Cloudでは活用
- 自前backendでは明示的なディレクトリ分離を優先
  - 設定ミスのリスク軽減
  - 視認性の向上

## 結果

- 環境ごとに独立したデプロイが可能
- 権限分離の実装が容易
- 運用時の影響範囲が明確
- state数は環境数（3: dev/stg/prd）で管理可能な範囲

## 参照

- [Terraform State](https://developer.hashicorp.com/terraform/language/state)
- [State Isolation](https://developer.hashicorp.com/terraform/language/state/workspaces)
