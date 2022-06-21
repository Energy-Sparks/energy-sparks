class CreateTransifexLoadErrors < ActiveRecord::Migration[6.0]
  def change
    create_table :transifex_load_errors do |t|
      t.string :record_type
      t.bigint :record_id
      t.string :error
      t.references :transifex_load, null: false, foreign_key: true, index: { name: :transifex_load_error_run_idx }
      t.timestamps
    end
  end
end
