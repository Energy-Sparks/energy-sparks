class AddDetailsToDataSource < ActiveRecord::Migration[7.2]
  def change
    add_reference :data_sources, :owned_by, foreign_key: { to_table: :users }
    change_column_default :data_sources, :import_warning_days, from: nil, to: 7
    change_table :data_sources, bulk: true do |t|
      t.boolean :alerts_on, default: true
      t.integer :alert_percentage_threshold
    end
  end
end
