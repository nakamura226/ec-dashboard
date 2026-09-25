module DashboardHelper
  def store_status_badge_class(status)
    case status.to_s
    when "active" then "badge-success"
    when "syncing" then "badge-warning"
    when "error" then "badge-error"
    else "badge-ghost"
    end
  end

  def sync_log_status_badge_class(status)
    case status.to_s
    when "success" then "badge-success"
    when "processing", "pending" then "badge-warning"
    when "failed" then "badge-error"
    else "badge-ghost"
    end
  end
end
