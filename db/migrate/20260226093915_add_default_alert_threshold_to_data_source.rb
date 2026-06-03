class AddDefaultAlertThresholdToDataSource < ActiveRecord::Migration[7.2]
  def change
    change_column_default :data_sources, :alert_percentage_threshold, from: nil, to: 25
  end
end
