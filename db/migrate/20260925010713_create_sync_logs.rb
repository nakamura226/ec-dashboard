class CreateSyncLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :sync_logs do |t|
      t.references :store, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.integer :fetched_count, null: false, default: 0
      t.text :error_message

      t.timestamps
    end
  end
end
