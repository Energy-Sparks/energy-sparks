class AddLatLongToAreas < ActiveRecord::Migration[5.2]
  def change
    add_column :areas, :latitude, :decimal, { precision: 10, scale: 6 }
    add_column :areas, :longitude, :decimal, { precision: 10, scale: 6 }
  end
end
