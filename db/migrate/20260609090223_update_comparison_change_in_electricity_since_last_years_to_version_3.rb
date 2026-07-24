# frozen_string_literal: true

class UpdateComparisonChangeInElectricitySinceLastYearsToVersion3 < ActiveRecord::Migration[8.1]
  def change
    update_view :comparison_change_in_electricity_since_last_years,
                version: 3,
                revert_to_version: 2,
                materialized: true
  end
end
