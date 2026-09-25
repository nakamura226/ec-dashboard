# CLAUDE.md - EC Multi-Channel Dashboard 開発プロンプト

あなた（Claude Code）は Ruby on Rails、Hotwire、Docker、およびフロントエンド開発のエキスパートです。
以下の要件定義と技術スタックに基づき、「ECモール連携 売上ダッシュボード」を段階的に実装してください。

---

## 1. プロジェクト概要 & 技術スタック

- **アプリ名**: EC Multi-Channel Dashboard
- **目的**: ECモールの擬似API連携と、Hotwireによるリアルタイム売上データの可視化プロトタイプ
- **Backend**: Ruby on Rails 8.0 (または 7.1+)
- **Database**: MySQL 8.0
- **Frontend**: Hotwire (Turbo, Stimulus), Tailwind CSS + DaisyUI
- **Job/Queue**: Solid Queue
- **インフラ/開発環境**: Docker / docker-compose

---

## 2. Docker 開発環境構成

まずはプロジェクト直下に以下の構成で Docker 環境を定義・作成してください。

- **`docker-compose.yml`**:
  - `web` サービス: Rails 8 アプリケーション
  - `db` サービス: MySQL 8.0（環境変数で接続・データベース名・パスワードを設定）
- **`Dockerfile`**:
  - Ruby 3.x をベースに、MySQL クライアントや依存パッケージをセットアップ
- `docker-compose up` 一発で Rails と MySQL が起動し、`bin/rails db:prepare` でDB構築が完了する状態を目指す。

---

## 3. データベース設計 (MySQL)

以下の3つのモデルおよびマイグレーションを作成してください。

1. **`Store` (店舗情報)**
   - `name`: string (例: "Amazon 公式ストア", "Shopify 本店")
   - `platform`: string (enum: `amazon`, `shopify`)
   - `api_key`: string
   - `status`: string (enum: `active`, `error`, `syncing`, default: `active`)
   - リレーション: `has_many :sales_records`, `has_many :sync_logs`

2. **`SalesRecord` (売上履歴)**
   - `store_id`: references (null: false, foreign_key: true)
   - `order_number`: string (INDEX付与)
   - `amount`: decimal (precision: 10, scale: 2)
   - `order_placed_at`: datetime
   - リレーション: `belongs_to :store`

3. **`SyncLog` (同期履歴)**
   - `store_id`: references (null: false, foreign_key: true)
   - `status`: string (enum: `pending`, `processing`, `success`, `failed`)
   - `fetched_count`: integer, default: 0
   - `error_message`: text
   - リレーション: `belongs_to :store`

---

## 4. モックAPIサービス & バックグラウンド処理

1. **Service Class** (`app/services/api_clients/`)
   - `ApiClients::BaseService`: 共通インターフェース
   - `ApiClients::AmazonService`: Amazon SP-API のモックレスポンス（ランダムな売上データの自動生成ロジックと `sleep 2` などの擬似通信遅延を含む）
   - `ApiClients::ShopifyService`: Shopify API のモックレスポンス処理
   - 実行結果として `SalesRecord` を作成し、`SyncLog` に処理結果（ステータス、取得件数）を記録する。

2. **ActiveJob** (`app/jobs/sync_ec_data_job.rb`)
   - `store_id` を受け取り、非同期で該当サービスの同期を実行。
   - 処理完了時、`Turbo::StreamsChannel` を通じてダッシュボード画面に最新の `SyncLog` と KPI 数値をリアルタイム配信（`broadcast_append_to` / `broadcast_replace_to`）する。

---

## 5. UI / デザインガイドライン要件

SaaS管理画面としての統一感と可読性を保つため、**DaisyUI** のUIガイドラインに従ってください。

- **レイアウト・トーン**: ダーク/ライトのモダンなSaaSダッシュボード
- **KPIコンポーネント**: DaisyUI の `stat` / `stats` クラスを使用して「本日の総売上」「当月累計売上」「最新同期状態」をカード表示。
- **ステータスバッジ**: DaisyUI の `badge` クラス（`badge-success`, `badge-warning`, `badge-error`）を活用して直感的に表現。
- **ログテーブル**: `table` / `table-zebra` でAPI同期履歴をきれいに整理。
- **手動同期ボタン**: クリック時に画面全体をリロードせず、Turbo Stream でローディング表示およびログのリアルタイム追加を実行する。

---

## 6. 開発の進め方

以下のステップで順番に実装し、各ステップ完了ごとに確認してください。

1. **Step 1**: Docker環境（`docker-compose.yml`, `Dockerfile`）の構築
2. **Step 2**: モデル・マイグレーション・シードデータ（`db/seeds.rb`）の作成
3. **Step 3**: `ApiClients` サービスおよび `SyncEcDataJob` の実装
4. **Step 4**: DaisyUI を適用したダッシュボード画面（`DashboardController`）と Hotwire (Turbo Stream) 配信の実装
