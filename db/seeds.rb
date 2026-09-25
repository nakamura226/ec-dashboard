# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

stores = [
  { name: "Amazon 公式ストア", platform: "amazon", api_key: "mock-amazon-key-001", status: "active" },
  { name: "Shopify 本店", platform: "shopify", api_key: "mock-shopify-key-001", status: "active" },
  { name: "Amazon サブストア", platform: "amazon", api_key: "mock-amazon-key-002", status: "error" }
].map do |attrs|
  Store.find_or_create_by!(name: attrs[:name]) do |store|
    store.platform = attrs[:platform]
    store.api_key = attrs[:api_key]
    store.status = attrs[:status]
  end
end

stores.each do |store|
  next if store.sales_records.exists?

  order_prefix = store.amazon? ? "AMZ" : "SHP"

  60.times do |i|
    placed_at = rand(30.days).seconds.ago

    store.sales_records.create!(
      order_number: "#{order_prefix}-#{format('%05d', i + 1)}",
      amount: rand(1_000..50_000),
      order_placed_at: placed_at
    )
  end
end

stores.each do |store|
  next if store.sync_logs.exists?

  3.times do |i|
    created_at = (3 - i).hours.ago

    if store.error?
      store.sync_logs.create!(
        status: "failed",
        fetched_count: 0,
        error_message: "APIキーが無効です。管理画面からキーを再設定してください。",
        created_at: created_at,
        updated_at: created_at
      )
    else
      store.sync_logs.create!(
        status: "success",
        fetched_count: rand(5..20),
        created_at: created_at,
        updated_at: created_at
      )
    end
  end
end

puts "Seeded #{Store.count} stores, #{SalesRecord.count} sales records, #{SyncLog.count} sync logs."
