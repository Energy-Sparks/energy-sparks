class AddDashboardToStaffRole < ActiveRecord::Migration[6.0]
  def change
    add_column :staff_roles, :dashboard, :integer, default: 0, null: false
  end
end
