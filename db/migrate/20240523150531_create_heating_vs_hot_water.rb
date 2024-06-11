class CreateHeatingVsHotWater < ActiveRecord::Migration[6.1]
  def change
    create_view :heating_vs_hot_waters
  end
end
