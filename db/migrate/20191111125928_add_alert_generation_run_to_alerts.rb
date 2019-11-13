class AddAlertGenerationRunToAlerts < ActiveRecord::Migration[6.0]
  def change
    add_reference(:alerts, :alert_generation_run, foreign_key: true, on_delete: :cascade)
  end
end
