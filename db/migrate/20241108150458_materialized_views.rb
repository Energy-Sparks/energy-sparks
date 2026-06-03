class MaterializedViews < ActiveRecord::Migration[7.1]
  def up
    %i[annual_change_in_electricity_out_of_hours_uses 2
       annual_change_in_gas_out_of_hours_uses 1
       annual_change_in_storage_heater_out_of_hours_uses 1
       annual_electricity_costs_per_pupils 1
       annual_electricity_out_of_hours_uses 1
       annual_energy_costs 1
       annual_energy_costs_per_units 1
       annual_energy_uses 1
       annual_gas_out_of_hours_uses 1
       annual_heating_costs_per_floor_areas 1
       annual_storage_heater_out_of_hours_uses 1
       baseload_per_pupils 1
       change_in_electricity_holiday_consumption_previous_holidays 1
       change_in_electricity_holiday_consumption_previous_years_holidays 1
       change_in_electricity_since_last_years 1
       change_in_energy_since_last_years 1
       change_in_energy_use_since_joined_energy_sparks 1
       change_in_gas_holiday_consumption_previous_holidays 1
       change_in_gas_holiday_consumption_previous_years_holidays 1
       change_in_gas_since_last_years 1
       change_in_solar_pv_since_last_years 1
       change_in_storage_heaters_since_last_years 1
       configurable_periods 3
       electricity_consumption_during_holidays 2
       electricity_peak_kw_per_pupils 1
       electricity_targets 2
       gas_consumption_during_holidays 1
       gas_targets 2
       heating_coming_on_too_early 1
       heating_in_warm_weathers 1
       heating_vs_hot_waters 1
       heat_saver_march_2024s 1
       holiday_and_terms 1
       holiday_usage_last_years 2
       hot_water_efficiencies 1
       recent_change_in_baseloads 1
       seasonal_baseload_variations 1
       solar_generation_summaries 1
       solar_pv_benefit_estimates 1
       storage_heater_consumption_during_holidays 1
       thermostatic_controls 1
       thermostat_sensitivities 1
       weekday_baseload_variations 1].each_slice(2) do |view, version|
      drop_view(view)
      view = :"comparison_#{view}"
      create_view(view, version: version.to_s.to_i, materialized: true)
      index_on = :school_id
      index_on = %i[school_id comparison_report_id] if view == :comparison_configurable_periods
      # allow views to refreshed concurrently
      add_index(view, index_on, unique: true)
    end
  end
end
