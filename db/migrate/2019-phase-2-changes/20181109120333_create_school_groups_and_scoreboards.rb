class CreateSchoolGroupsAndScoreboards < ActiveRecord::Migration[5.2]
  def change

    create_table :scoreboards do |t|
      t.string :name, null: false
      t.string :description
      t.string :slug, null: false
      t.timestamps
    end

    create_table :school_groups do |t|
      t.string :name, null: false
      t.string :description
      t.string :slug, null: false
      t.references :scoreboard, foreign_key: true
      t.timestamps
    end

    add_reference :schools, :school_group, foreign_key: true

  end
end
