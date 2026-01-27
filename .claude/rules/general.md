# claude.md — Azure VM + Bastion + Public IP + Terraform Cloud (CI/CD)

このリポジトリは **Azure 上に仮想マシン (VM) を構築**し、**Azure Bastion で管理アクセス**できるようにしつつ、**VM に Public IP を付与してインターネット通信**できる構成を **Terraform** でコード化します。  
CI/CD（Plan/Apply）は **Terraform Cloud** を使用します。

---

## 1. ゴール / 要件（必須）

- Azure 上に以下を Terraform で作成する
  - Resource Group
  - Virtual Network / Subnet（VM 用）
  - `AzureBastionSubnet`（Bastion 用、名前固定）
  - Network Security Group（VM 用）
  - Public IP（Bastion 用）
  - Public IP（VM 用）
  - NIC（VM 用、Public IP を関連付け）
  - VM（Linux 推奨: SSH、Windowsでも可）
  - Azure Bastion（Standard 推奨）
- 管理アクセスは **Bastion 経由**（※原則 VM への 22/3389 公開はしない）
- VM は **Public IP を持つ**（インターネットとの通信が可能）
- Terraform の実行は **Terraform Cloud ワークスペース**で行う（ローカル state は使わない）

---

## 2. 重要な設計方針（セキュリティ含む）

### 2.1 Bastion を使う前提
- **VM の管理ポート(22/3389)はインターネットに公開しない**
- Bastion からの接続に必要な通信のみを NSG で許可する（後述）

### 2.2 VM に Public IP を付与する前提
ユーザー要件として VM に Public IP を付与する。  
ただし Public IP を付けると「インターネットから到達可能」になり得るため、次を徹底する。

- NSG の Inbound は **原則 Deny**
- どうしても公開が必要な場合は
  - 公開ポートを最小化（例: 80/443 のみ）
  - 送信元を限定（特定 IP / WAF / Front Door / Application Gateway 等を検討）
- Outbound は通常許可（既定で許可されるが、要件に応じて制御）

---

## 3. 想定アーキテクチャ（最小）

- VNet: `10.0.0.0/16`
  - Subnet (VM): `10.0.1.0/24`
  - Subnet (Bastion): `10.0.2.0/27` 以上（**/27 以上必須**、名前は **AzureBastionSubnet**）
- VM: 1 台
- Bastion: 1 台（VNet 内）
- Public IP:
  - Bastion 用: 1 つ（Standard / Static 推奨）
  - VM 用: 1 つ（Standard / Static 推奨）

---

## 4. リポジトリ構成（推奨）

```
.
├─ README.md
├─ claude.md
├─ infra/
│ ├─ main.tf
│ ├─ variables.tf
│ ├─ outputs.tf
│ ├─ versions.tf
│ ├─ locals.tf
│ └─ modules/
│ ├─ network/
│ ├─ bastion/
│ └─ vm/
└─ .gitignore
```

> まずは `infra/` 直下に全部置いてもよい。安定したら modules 分割。

---

## 5. Terraform 実装ルール

すでにテンプレートが用意されているため、基本的にはテンプレートに沿って作成すること。
以下の内容は必要に応じて参照とする。

### 5.1 Provider / Version
- `azurerm` provider を使用
- `features {}` を必ず定義
- `terraform { cloud { ... } }` を利用して Terraform Cloud をバックエンドにする

### 5.2 命名
- すべてのリソース名は `project` と `env` を含める（例: `proj-dev-vnet`）
- `env` は `dev` / `stg` / `prod` を想定（最低 dev）

### 5.3 変数（最低限）
- `project`（例: `demo`）
- `env`（例: `dev`）
- `location`（例: `japaneast`）
- `admin_username`
- `ssh_public_key`（Linux の場合）
- `vm_size`（例: `Standard_B2s`）
- `allowed_inbound_cidrs`（必要時のみ：80/443 を開ける等）

### 5.4 Outputs（最低限）
- `vm_public_ip`
- `vm_private_ip`
- `bastion_id` / `bastion_name`
- `resource_group_name`

---

## 6. NSG 方針（推奨の最小）

### 6.1 Inbound
- 22/3389 を **Internet から許可しない**
- 公開が必要なアプリ用ポートがあるなら、それだけ許可（例: 80/443）
  - 送信元 `allowed_inbound_cidrs` で制限できるようにする

### 6.2 Bastion から VM への管理アクセス
- Bastion は同一 VNet 内から VM に到達するので、VM の NIC / Subnet 側で
  - 22 (Linux) または 3389 (Windows) を **VNet 内からの通信**として許可する
  - 送信元を厳密に Bastion サブネットに限定するのが理想（`10.0.2.0/27` 等）

---

## 7. Terraform Cloud（CI/CD）運用ルール

### 7.1 実行方式
- Terraform Cloud の Workspace を作り、VCS 連携（GitHub 等）で **PR 時に Plan / Merge 後に Apply**
  - Apply は「Auto Apply なし（手動承認）」を推奨（少なくとも dev 以外）

### 7.2 Workspace 設定
- Working Directory: `infra/`
- Variables:
  - Terraform Variables: `project`, `env`, `location`, `admin_username`, `ssh_public_key`, `vm_size`
  - Environment Variables（Azure 認証）:
    - `ARM_CLIENT_ID`
    - `ARM_CLIENT_SECRET`（Sensitive）
    - `ARM_SUBSCRIPTION_ID`
    - `ARM_TENANT_ID`

> Azure への認証はまず Service Principal で進める（将来 OIDC 方式へ移行してもよい）。

### 7.3 期待する CI/CD の流れ
1. PR 作成 → Terraform Cloud が Plan
2. Plan 結果レビュー（差分・破壊がないか）
3. PR Merge → Apply（dev は自動でも可、prod は手動承認）

---

## 8. 作業手順（この順で進める）

1. Azure 側で Service Principal 作成（Contributor 以上を対象 Subscription に付与）
2. Terraform Cloud で Organization 作成
3. Workspace 作成（Working Directory を `infra/` に設定）
4. Workspace に Azure 認証情報（ARM_*）を登録
5. Terraform で以下の順にリソースをコード化
   - RG
   - VNet + Subnets（VM subnet / AzureBastionSubnet）
   - NSG + NIC
   - Public IP（VM）
   - VM
   - Public IP（Bastion）
   - Bastion
6. PR → Plan → Apply で構築
7. Azure Portal で Bastion から VM に接続確認
8. VM がインターネット通信可能か確認（例: OS 内から `curl` / `apt update` 等）

---

## 9. 受け入れ条件（Definition of Done）

- Terraform Cloud から `terraform apply` 相当が成功する
- Azure Bastion 経由で VM にログインできる
- VM に Public IP が付与されている（Terraform output でも確認できる）
- VM がインターネットへ疎通できる（Outbound）
- NSG で 22/3389 が Internet から開いていない（Bastion 専用）

---

## 10. よくあるハマりどころ（チェックリスト）

- Bastion のサブネット名が `AzureBastionSubnet` になっていない
- `AzureBastionSubnet` のサイズが小さすぎる（/27 未満）
- Bastion 用 Public IP が Standard でない / 動的になっている
- NSG が厳しすぎて Bastion から VM の 22/3389 が通らない
- Terraform Cloud の Working Directory 設定ミス（`infra/` を指していない）
- ARM_* の値が誤っている（Subscription/Tenant の取り違え）

---

## 11. Claude（このリポジトリでの振る舞い）

- 変更は必ず `infra/` 配下に閉じる
- 破壊的変更（RG 破棄、VNet 作り直し等）が出る場合は、理由と回避策をコメントとして提案する
- セキュリティ優先：
  - VM の管理ポートは Internet に開けない
  - 公開ポートは最小化し、CIDR 制限できるようにする
- 生成する Terraform は「読みやすさ」を優先し、`locals` と `variables` を活用する
