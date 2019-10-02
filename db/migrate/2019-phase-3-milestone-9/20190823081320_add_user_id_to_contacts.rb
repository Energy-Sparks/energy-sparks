class AddUserIdToContacts < ActiveRecord::Migration[6.0]
  def change
    add_reference :contacts, :user, foreign_key: {on_delete: :cascade}
    add_reference :contacts, :staff_role, foreign_key: {on_delete: :restrict}
  end
end
