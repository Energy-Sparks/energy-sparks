class AddSchoolIdAndFuelTypeToWarnings < ActiveRecord::Migration[6.0]
  def change
    add_column :amr_reading_warnings, :school_id, :integer
    add_column :amr_reading_warnings, :fuel_type, :string
  end
end
