class AddSchoolGroupTypeToSchoolGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :school_groups, :school_group_type, :integer, default: 0
  end
end
