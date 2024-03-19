class CreateHotWaterEfficiencies < ActiveRecord::Migration[6.1]
  def change
    create_view :hot_water_efficiencies
  end
end
