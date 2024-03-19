class CreateAnnualHeatingCostsPerFloorAreas < ActiveRecord::Migration[6.1]
  def change
    create_view :annual_heating_costs_per_floor_areas
  end
end
