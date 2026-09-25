class DashboardController < ApplicationController
  def index
    @stores = Store.order(:name)
    @sync_logs = SyncLog.includes(:store).order(created_at: :desc).limit(20).to_a.reverse

    kpis = DashboardKpiCalculator.call
    @today_total = kpis[:today_total]
    @month_total = kpis[:month_total]
    @latest_sync_log = kpis[:latest_sync_log]
  end
end
