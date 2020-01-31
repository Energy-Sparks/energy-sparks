class AddLatLngToSchool < ActiveRecord::Migration[6.0]
  def change
    add_column :schools, :latitude, :decimal, { precision: 10, scale: 6 }
    add_column :schools, :longitude, :decimal, { precision: 10, scale: 6 }
  end
end
