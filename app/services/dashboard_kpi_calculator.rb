class DashboardKpiCalculator
  def self.call
    new.call
  end

  def call
    {
      today_total: SalesRecord.where(order_placed_at: Time.zone.now.all_day).sum(:amount),
      month_total: SalesRecord.where(order_placed_at: Time.zone.now.all_month).sum(:amount),
      latest_sync_log: SyncLog.order(created_at: :desc).first
    }
  end
end
