# frozen_string_literal: true

class UpdateComparisonChangeInGasSinceLastYearsToVersion2 < ActiveRecord::Migration[8.1]
  def change
    update_view :comparison_change_in_gas_since_last_years,
                version: 2,
                revert_to_version: 1,
                materialized: true
  end
end
