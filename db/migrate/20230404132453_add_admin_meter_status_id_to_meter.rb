class AddAdminMeterStatusIdToMeter < ActiveRecord::Migration[6.0]
  def change
    add_column :meters, :admin_meter_statuses_id, :bigint
  end
end
