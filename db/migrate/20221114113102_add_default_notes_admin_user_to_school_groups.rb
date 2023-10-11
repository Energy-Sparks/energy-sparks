class AddDefaultNotesAdminUserToSchoolGroups < ActiveRecord::Migration[6.0]
  def change
    add_reference :school_groups, :default_notes_admin_user, foreign_key: { to_table: :users, on_delete: :nullify }
  end
end
