class UpdateComparisonAnnualHeatingCostsPerFloorAreasToVersion2 < ActiveRecord::Migration[7.2]
  def change
    update_view :comparison_annual_heating_costs_per_floor_areas,
                version: 2,
                revert_to_version: 1,
                materialized: { side_by_side: true }
  end
end
