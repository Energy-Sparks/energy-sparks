class CreateSchoolsManualReadings < ActiveRecord::Migration[7.2]
  def change
    create_table :schools_manual_readings do |t|
      t.references :school, null: false, foreign_key: { on_delete: :cascade }
      t.date :month, null: false
      t.integer :electricity
      t.integer :gas

      t.timestamps

      t.index %i[school_id month], unique: true
    end
  end
end
