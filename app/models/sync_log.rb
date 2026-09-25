class SyncLog < ApplicationRecord
  enum :status, { pending: "pending", processing: "processing", success: "success", failed: "failed" }, default: "pending"

  belongs_to :store
end
