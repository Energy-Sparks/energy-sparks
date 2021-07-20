class CreateSchoolTargets < ActiveRecord::Migration[6.0]
  def change
    create_table :school_targets do |t|
      t.references :school, null: false, foreign_key: true
      t.date :target
      t.integer :electricity
      t.integer :gas
      t.integer :storage_heaters

      t.timestamps
    end
  end
end
