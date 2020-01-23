class CreateTeamMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :team_members do |t|
      t.string  :title, null: false
      t.text    :description
      t.integer :position, null: false, default: 0
      t.timestamps
    end
  end
end
