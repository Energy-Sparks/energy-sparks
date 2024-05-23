class RemoveCustomPeriodFromAlerts < ActiveRecord::Migration[6.1]
  def change
    remove_reference :alerts, :custom_period, foreign_key: { to_table: 'comparison_custom_periods', on_delete: :cascade }
  end
end
