class CreateBenchmarkResults < ActiveRecord::Migration[6.0]
  def change
    create_table :benchmark_results do |t|
      t.references  :alert_generation_run
      t.references  :alert_type
      t.date        :asof
      t.text        :data
      t.timestamps
    end
  end
end
