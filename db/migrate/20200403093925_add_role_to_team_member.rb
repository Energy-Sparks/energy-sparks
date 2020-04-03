class AddRoleToTeamMember < ActiveRecord::Migration[6.0]
  def change
    add_column :team_members, :role, :integer
  end
end
