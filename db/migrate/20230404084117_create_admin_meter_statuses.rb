class CreateAdminMeterStatuses < ActiveRecord::Migration[6.0]
  def change
    create_table :admin_meter_statuses do |t|
      t.string :label

      t.timestamps
    end
  end
end
