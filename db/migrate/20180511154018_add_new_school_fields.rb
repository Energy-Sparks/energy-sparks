class AddNewSchoolFields < ActiveRecord::Migration[5.1]
  def change
    add_column :schools, :calendar_area_id, :integer, index: true
    add_column :schools, :temperature_area_id, :integer, index: true
    add_column :schools, :solar_irradiance_area_id, :integer, index: true
    add_column :schools, :solar_pv_area_id, :integer, index: true
    add_column :schools, :met_office_area_id, :integer, index: true
  end
end
