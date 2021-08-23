class RemoveDashboardFromStaffRole < ActiveRecord::Migration[6.0]
  def up
    remove_column :staff_roles, :dashboard
  end

  def down
    add_column :staff_roles, :dashboard, :integer, default: 0, null: false
  end
end
