module ApiClients
  class ShopifyService < BaseService
    private

    def fetch_sales_data
      sleep 1 # Shopify API との擬似通信遅延

      simulate_transient_failure!(
        probability: 0.1,
        message: "Shopify API: 認証トークンの有効期限が切れています"
      )

      rand(3..10).times.map do
        {
          order_number: "SHP-#{SecureRandom.hex(5).upcase}",
          amount: rand(1_000..50_000),
          order_placed_at: rand(0..48).hours.ago
        }
      end
    end
  end
end
