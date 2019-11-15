class CreateBenchmarkResultError < ActiveRecord::Migration[6.0]
  def change
    create_table :benchmark_result_errors do |t|
      t.references :benchmark_result_generation_run, null: false, foreign_key: { on_delete: :cascade }, index: {name: 'ben_rgr_errors_index'}
      t.references :alert_type, null: false, foreign_key: { on_delete: :cascade }
      t.date        :asof_date
      t.text        :information
      t.timestamps
    end
  end
end
