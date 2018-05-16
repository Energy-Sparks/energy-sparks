class AddNewSchoolFields < ActiveRecord::Migration[5.1]
  def change
    add_column :schools, :group_id,   :integer, index: true
  end
end
