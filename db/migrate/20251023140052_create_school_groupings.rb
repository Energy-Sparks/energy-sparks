class CreateSchoolGroupings < ActiveRecord::Migration[7.2]
  def change
    create_enum :school_grouping_role, %w[organisation area project]

    create_table :school_groupings do |t|
      t.references :school, null: false, foreign_key: true
      t.references :school_group, null: false, foreign_key: true
      t.enum :role, enum_type: :school_grouping_role, null: false

      t.timestamps
    end

    # Add partial unique index to enforce one "organisation" group per school
    add_index :school_groupings, [:school_id, :role],
              unique: true,
              where: "role = 'organisation'",
              name: 'index_school_groupings_on_school_id_and_organisation_role'
  end
end
