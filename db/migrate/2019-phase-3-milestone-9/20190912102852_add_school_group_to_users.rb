class AddSchoolGroupToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :school_group, foreign_key: {on_delete: :restrict}
  end
end
