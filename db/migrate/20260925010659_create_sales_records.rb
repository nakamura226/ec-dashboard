class CreateSalesRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :sales_records do |t|
      t.references :store, null: false, foreign_key: true
      t.string :order_number, null: false, index: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.datetime :order_placed_at, null: false

      t.timestamps
    end
  end
end
