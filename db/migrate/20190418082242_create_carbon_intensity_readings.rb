class CreateCarbonIntensityReadings < ActiveRecord::Migration[5.2]
  def change
    create_table :carbon_intensity_readings do |t|
      t.date          :reading_date,          null: false
      t.decimal       :carbon_intensity_x48,  null: false, array: true
      t.timestamps
    end

    add_index :carbon_intensity_readings, :reading_date, unique: true
  end
end
