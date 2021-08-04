class CreateSchoolTargets < ActiveRecord::Migration[6.0]
  def change
    create_table :school_targets do |t|
      t.references :school, null: false, foreign_key: true
      t.date :target_date
      t.date :start_date
      t.float :electricity
      t.float :gas
      t.float :storage_heaters

      t.timestamps
    end
  end
end
