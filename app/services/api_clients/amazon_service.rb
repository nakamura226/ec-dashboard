module ApiClients
  class AmazonService < BaseService
    private

    def fetch_sales_data
      sleep 2 # Amazon SP-API との擬似通信遅延

      simulate_transient_failure!(
        probability: 0.1,
        message: "Amazon SP-API: 一時的なレート制限エラーが発生しました (429 Too Many Requests)"
      )

      rand(3..10).times.map do
        {
          order_number: "AMZ-#{SecureRandom.hex(5).upcase}",
          amount: rand(1_000..50_000),
          order_placed_at: rand(0..48).hours.ago
        }
      end
    end
  end
end
