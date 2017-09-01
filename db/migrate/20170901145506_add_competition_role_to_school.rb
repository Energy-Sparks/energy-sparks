class AddCompetitionRoleToSchool < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :competition_role, :integer
  end
end
