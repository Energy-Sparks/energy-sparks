class AddAdminMeterStatusesIdToSchoolGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :school_groups, :admin_meter_statuses_id, :bigint
  end
end
