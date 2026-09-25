class CreateStores < ActiveRecord::Migration[8.1]
  def change
    create_table :stores do |t|
      t.string :name, null: false
      t.string :platform, null: false
      t.string :api_key
      t.string :status, null: false, default: "active"

      t.timestamps
    end
  end
end
