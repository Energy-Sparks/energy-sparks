class UpdateComparisonHeatingInWarmWeathersToVersion2 < ActiveRecord::Migration[7.2]
  def change
    update_view :comparison_heating_in_warm_weathers, version: 2, revert_to_version: 1, materialized: true
  end
end
