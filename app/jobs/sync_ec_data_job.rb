class SyncEcDataJob < ApplicationJob
  queue_as :default

  SERVICE_CLASSES = {
    "amazon" => ApiClients::AmazonService,
    "shopify" => ApiClients::ShopifyService
  }.freeze

  def perform(store_id)
    store = Store.find(store_id)
    service_class = SERVICE_CLASSES.fetch(store.platform)

    sync_log = service_class.new(store).call

    broadcast_sync_log(sync_log)
    broadcast_kpis
  end

  private

  def broadcast_sync_log(sync_log)
    Turbo::StreamsChannel.broadcast_append_to(
      "dashboard",
      target: "sync_logs",
      partial: "sync_logs/sync_log",
      locals: { sync_log: sync_log }
    )
  end

  def broadcast_kpis
    Turbo::StreamsChannel.broadcast_replace_to(
      "dashboard",
      target: "kpi_stats",
      partial: "dashboard/kpi_stats",
      locals: DashboardKpiCalculator.call
    )
  end
end
