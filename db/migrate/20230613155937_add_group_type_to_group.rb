class AddGroupTypeToGroup < ActiveRecord::Migration[6.0]
  def up
    add_column :school_groups, :group_type, :integer, default: 0
  end

  def down
    remove_column :school_groups, :group_type
  end
end
