class AddSchoolAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :number_of_pupils, :integer
    add_column :schools, :floor_area, :decimal
    add_column :schools, :weather_underground_area_id, :integer
    add_column :schools, :solar_pv_tuos_area_id, :integer
  end
end
