class DropStatusFromAlerts < ActiveRecord::Migration[6.0]
  def up
    remove_column :alerts, :status
  end
end
