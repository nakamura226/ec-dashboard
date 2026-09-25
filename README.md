# EC Multi-Channel Dashboard

ECモール（Amazon / Shopify）連携の擬似API通信と、Hotwire（Turbo Streams）によるリアルタイム売上ダッシュボードのプロトタイプです。

## 技術スタック

- Ruby on Rails 8.1 / Ruby 3.3
- MySQL 8.0
- Hotwire (Turbo, Stimulus) / Tailwind CSS + DaisyUI
- Solid Queue (バックグラウンドジョブ)
- Docker / Docker Compose

## セットアップ（Docker）

```bash
cp .env.example .env   # 必要に応じてポートやパスワードを変更
docker compose build
docker compose up
```

- Rails アプリ: http://localhost:3000 (`WEB_PORT` で変更可能)
- `db` コンテナ起動後、`web` コンテナの起動時に自動で `bin/rails db:prepare` が実行され、DB が作成・マイグレーションされます。
- ジョブワーカー（Solid Queue）は `worker` サービスとして別コンテナで起動します。

### よく使うコマンド

```bash
# コンテナに入って rails コマンドを実行
docker compose run --rm web bin/rails console
docker compose run --rm web bin/rails db:seed

# マイグレーション作成後に反映
docker compose run --rm web bin/rails db:migrate
```
