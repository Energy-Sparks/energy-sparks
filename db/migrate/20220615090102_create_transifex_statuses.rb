class CreateTransifexStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :transifex_statuses do |t|
      t.string :record_type, null: false
      t.bigint :record_id, null: false
      t.datetime :tx_created_at
      t.datetime :tx_last_push
      t.datetime :tx_last_pull
      t.timestamps
      t.index %w[record_type record_id], name: 'index_transifex_statuses_uniqueness', unique: true
    end
  end
end
