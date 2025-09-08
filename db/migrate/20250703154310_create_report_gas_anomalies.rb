class CreateReportGasAnomalies < ActiveRecord::Migration[7.2]
  def change
    create_view :report_gas_anomalies, materialized: true
    add_index :report_gas_anomalies, :id, unique: true
  end
end
