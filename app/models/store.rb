class Store < ApplicationRecord
  enum :platform, { amazon: "amazon", shopify: "shopify" }
  enum :status, { active: "active", error: "error", syncing: "syncing" }, default: "active"

  has_many :sales_records, dependent: :destroy
  has_many :sync_logs, dependent: :destroy

  validates :name, presence: true
  validates :platform, presence: true
end
