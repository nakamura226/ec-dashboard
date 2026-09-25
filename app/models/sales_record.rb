class SalesRecord < ApplicationRecord
  belongs_to :store

  validates :order_number, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :order_placed_at, presence: true
end
