class CreateReportBaseloadAnomalies < ActiveRecord::Migration[7.2]
  def change
    create_view :report_baseload_anomalies, materialized: true
    add_index :report_baseload_anomalies, :id, unique: true
  end
end
