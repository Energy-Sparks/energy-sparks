class AddStaffRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :staff_roles do |t|
      t.string :title, null: false
      t.timestamps
    end

    add_reference :users, :staff_role, foreign_key: {on_delete: :restrict}
  end
end
