class MoveScoreboardsToSchools < ActiveRecord::Migration[6.0]
  def change
    add_reference :schools, :scoreboard, foreign_key: {on_delete: :nullify}
    add_reference :school_onboardings, :scoreboard, foreign_key: {on_delete: :nullify}
    reversible do |dir|
      dir.up do
        connection.execute 'UPDATE schools SET scoreboard_id = school_groups.scoreboard_id FROM school_groups WHERE schools.school_group_id = school_groups.id'
      end
    end
    rename_column :school_groups, :scoreboard_id, :default_scoreboard_id
  end
end
