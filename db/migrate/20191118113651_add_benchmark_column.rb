class AddBenchmarkColumn < ActiveRecord::Migration[6.0]
  def change
    add_column :alert_types, :benchmark, :boolean, default: false
  end
end
