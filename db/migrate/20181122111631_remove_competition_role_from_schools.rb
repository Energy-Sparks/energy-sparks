class RemoveCompetitionRoleFromSchools < ActiveRecord::Migration[5.2]
  def up
    remove_column :schools, :competition_role
  end

  def down
    add_column :schools, :competition_role, :integer, default: 0
  end
end
