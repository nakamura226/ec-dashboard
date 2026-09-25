module ApiClients
  class BaseService
    class SyncError < StandardError; end

    attr_reader :store

    def initialize(store)
      @store = store
    end

    # Runs a full sync cycle: records a SyncLog, fetches (mock) sales data,
    # persists it as SalesRecords, and updates the store/log status accordingly.
    def call
      sync_log = store.sync_logs.create!(status: "processing", fetched_count: 0)
      store.update!(status: "syncing")

      begin
        created_records = fetch_sales_data.map { |attrs| store.sales_records.create!(attrs) }

        sync_log.update!(status: "success", fetched_count: created_records.size)
        store.update!(status: "active")
      rescue => e
        sync_log.update!(status: "failed", fetched_count: 0, error_message: e.message)
        store.update!(status: "error")
      end

      sync_log
    end

    private

    # Subclasses must return an Array of Hashes with :order_number, :amount, :order_placed_at
    def fetch_sales_data
      raise NotImplementedError, "#{self.class} must implement #fetch_sales_data"
    end

    def simulate_transient_failure!(probability:, message:)
      raise SyncError, message if rand < probability
    end
  end
end
