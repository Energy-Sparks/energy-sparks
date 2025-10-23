class AddMeterStatusIgnoreFlag < ActiveRecord::Migration[7.2]
  def change
    add_column :admin_meter_statuses, :ignore_in_inactive_meter_report, :boolean, default: false
  end
end
