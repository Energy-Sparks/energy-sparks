# frozen_string_literal: true

require 'spec_helper'
require 'active_support/core_ext'

describe Benchmarking::BenchmarkManager, type: :service do
  describe '#structured_pages' do
    it 'returns benchmarks by group for admin user types' do
      expect(described_class.structured_pages({ user_role: :admin })).to eq(
        [
          {
            name: 'Total Energy Use Benchmarks',
            description: 'These benchmarks compare the combined energy use of a school site',
            benchmarks: {
              annual_energy_costs: 'Annual cost of electricity, gas, storage heaters and combined energy',
              annual_energy_costs_per_floor_area: 'Annual energy cost per floor area',
              annual_energy_costs_per_pupil: 'Annual energy use per pupil',
              change_in_energy_since_last_year: 'Annual change in total energy use',
              holiday_usage_last_year: 'Cost of energy used in upcoming holiday last year'
            }
          },
          {
            name: 'Electricity Benchmarks',
            description: "These benchmarks compare schools' electricity consumption, including last year's consumption, recent and long term changes in consumption, baseload and performance against the school's target.",
            benchmarks: {
              annual_electricity_costs_per_pupil: 'Annual electricity use per pupil with savings potential',
              annual_electricity_out_of_hours_use: 'Electricity used out of school hours',
              baseload_per_pupil: 'Baseload per pupil',
              change_in_electricity_consumption_recent_school_weeks: 'Recent change in electricity use',
              change_in_electricity_holiday_consumption_previous_holiday: 'Change in electricity use between the last two holidays',
              change_in_electricity_holiday_consumption_previous_years_holiday: 'Change in electricity use between this holiday and the same holiday last year',
              change_in_electricity_since_last_year: 'Annual change in electricity use',
              electricity_consumption_during_holiday: 'Electricity use during current holiday',
              electricity_peak_kw_per_pupil: 'Peak school day electricity use',
              electricity_targets: 'Progress against electricity target',
              recent_change_in_baseload: 'Recent change in baseload',
              seasonal_baseload_variation: 'Seasonal baseload variation',
              weekday_baseload_variation: 'Weekday baseload variation',
              annual_change_in_electricity_out_of_hours_use: 'Annual change in electricity used out of school hours'
            }
          },
          {
            name: 'Gas and Storage Heater Benchmarks',
            description: "These benchmarks compare schools' gas or storage heater consumption, including last year's consumption, recent and long term changes in consumption, the standard of their heating control and performance against the school's target.",
            benchmarks: {
              annual_gas_out_of_hours_use: 'Gas used out of school hours',
              annual_heating_costs_per_floor_area: 'Annual heating cost per floor area with savings potential',
              annual_storage_heater_out_of_hours_use: 'Storage heaters used out of school hours',
              change_in_gas_consumption_recent_school_weeks: 'Recent change in gas use',
              change_in_gas_holiday_consumption_previous_holiday: 'Change in gas use between the last two holidays',
              change_in_gas_holiday_consumption_previous_years_holiday: 'Change in gas use between this holiday and the same holiday last year',
              change_in_gas_since_last_year: 'Annual change in gas use',
              change_in_storage_heaters_since_last_year: 'Annual change in storage heater',
              gas_consumption_during_holiday: 'Gas use during current holiday',
              gas_targets: 'Progress against gas target',
              heating_coming_on_too_early: 'Heating start time',
              heating_in_warm_weather: 'Heating used in warm weather',
              hot_water_efficiency: 'Hot Water Efficiency',
              storage_heater_consumption_during_holiday: 'Storage heater use during current holiday',
              thermostat_sensitivity: 'Annual saving through 1C reduction in thermostat temperature',
              thermostatic_control: 'Quality of thermostatic control',
              annual_change_in_gas_out_of_hours_use: 'Annual change in gas used out of school hours',
              annual_change_in_storage_heater_out_of_hours_use: 'Annual change in storage heater usage out of school hours'
            }
          },
          {
            name: 'Solar Benchmarks',
            description: "These benchmarks compare schools' solar PV production and the benefits of installing solar.",
            benchmarks: {
              change_in_solar_pv_since_last_year: 'Annual change in solar PV production and resulting CO2 savings',
              solar_pv_benefit_estimate: 'Benefit of solar PV installation',
              solar_generation_summary: 'Solar generation summary'
            }
          },
          {
            name: 'Date limited comparisons',
            description: 'These benchmarks compare schools performance across specific date ranges.',
            benchmarks: {
              change_in_energy_use_since_joined_energy_sparks: 'Change in energy use since the school joined Energy Sparks',
              jan_august_2022_2023_energy_comparison: 'Jan to August 2022 to 2023 energy use',
              layer_up_powerdown_day_november_2023: 'Change in energy for layer up power down day 24 November 2023 (compared with 17 November 2023)',
              heat_saver_march_2024: 'Heat Saver March 2024'
            }
          }
        ]
      )
    end

    it 'returns benchmarks by group for analyst user types' do
      expect(described_class.structured_pages({ user_role: :analyst })).to eq(
        [
          {
            name: 'Total Energy Use Benchmarks',
            description: 'These benchmarks compare the combined energy use of a school site',
            benchmarks: {
              annual_energy_costs: 'Annual cost of electricity, gas, storage heaters and combined energy',
              annual_energy_costs_per_floor_area: 'Annual energy cost per floor area',
              annual_energy_costs_per_pupil: 'Annual energy use per pupil',
              change_in_energy_since_last_year: 'Annual change in total energy use',
              holiday_usage_last_year: 'Cost of energy used in upcoming holiday last year'
            }
          },
          {
            name: 'Electricity Benchmarks',
            description: "These benchmarks compare schools' electricity consumption, including last year's consumption, recent and long term changes in consumption, baseload and performance against the school's target.",
            benchmarks: {
              annual_electricity_costs_per_pupil: 'Annual electricity use per pupil with savings potential',
              annual_electricity_out_of_hours_use: 'Electricity used out of school hours',
              baseload_per_pupil: 'Baseload per pupil',
              change_in_electricity_consumption_recent_school_weeks: 'Recent change in electricity use',
              change_in_electricity_holiday_consumption_previous_holiday: 'Change in electricity use between the last two holidays',
              change_in_electricity_holiday_consumption_previous_years_holiday: 'Change in electricity use between this holiday and the same holiday last year',
              change_in_electricity_since_last_year: 'Annual change in electricity use',
              electricity_consumption_during_holiday: 'Electricity use during current holiday',
              electricity_peak_kw_per_pupil: 'Peak school day electricity use',
              electricity_targets: 'Progress against electricity target',
              recent_change_in_baseload: 'Recent change in baseload',
              seasonal_baseload_variation: 'Seasonal baseload variation',
              weekday_baseload_variation: 'Weekday baseload variation',
              annual_change_in_electricity_out_of_hours_use: 'Annual change in electricity used out of school hours'
            }
          },
          {
            name: 'Gas and Storage Heater Benchmarks',
            description: "These benchmarks compare schools' gas or storage heater consumption, including last year's consumption, recent and long term changes in consumption, the standard of their heating control and performance against the school's target.",
            benchmarks: {
              annual_gas_out_of_hours_use: 'Gas used out of school hours',
              annual_heating_costs_per_floor_area: 'Annual heating cost per floor area with savings potential',
              annual_storage_heater_out_of_hours_use: 'Storage heaters used out of school hours',
              change_in_gas_consumption_recent_school_weeks: 'Recent change in gas use',
              change_in_gas_holiday_consumption_previous_holiday: 'Change in gas use between the last two holidays',
              change_in_gas_holiday_consumption_previous_years_holiday: 'Change in gas use between this holiday and the same holiday last year',
              change_in_gas_since_last_year: 'Annual change in gas use',
              change_in_storage_heaters_since_last_year: 'Annual change in storage heater',
              gas_consumption_during_holiday: 'Gas use during current holiday',
              gas_targets: 'Progress against gas target',
              heating_coming_on_too_early: 'Heating start time',
              heating_in_warm_weather: 'Heating used in warm weather',
              hot_water_efficiency: 'Hot Water Efficiency',
              storage_heater_consumption_during_holiday: 'Storage heater use during current holiday',
              thermostat_sensitivity: 'Annual saving through 1C reduction in thermostat temperature',
              thermostatic_control: 'Quality of thermostatic control',
              annual_change_in_gas_out_of_hours_use: 'Annual change in gas used out of school hours',
              annual_change_in_storage_heater_out_of_hours_use: 'Annual change in storage heater usage out of school hours'
            }
          },
          {
            name: 'Solar Benchmarks',
            description: "These benchmarks compare schools' solar PV production and the benefits of installing solar.",
            benchmarks: {
              change_in_solar_pv_since_last_year: 'Annual change in solar PV production and resulting CO2 savings',
              solar_pv_benefit_estimate: 'Benefit of solar PV installation',
              solar_generation_summary: 'Solar generation summary'
            }
          },
          {
            name: 'Date limited comparisons',
            description: 'These benchmarks compare schools performance across specific date ranges.',
            benchmarks: {
              change_in_energy_use_since_joined_energy_sparks: 'Change in energy use since the school joined Energy Sparks',
              jan_august_2022_2023_energy_comparison: 'Jan to August 2022 to 2023 energy use',
              layer_up_powerdown_day_november_2023: 'Change in energy for layer up power down day 24 November 2023 (compared with 17 November 2023)',
              heat_saver_march_2024: 'Heat Saver March 2024'
            }
          }
        ]
      )
    end

    it 'returns benchmarks by group for guest user types' do
      expect(described_class.structured_pages({ user_role: :guest })).to eq(
        [
          {
            name: 'Total Energy Use Benchmarks',
            description: 'These benchmarks compare the combined energy use of a school site',
            benchmarks: {
              annual_energy_costs: 'Annual cost of electricity, gas, storage heaters and combined energy',
              annual_energy_costs_per_floor_area: 'Annual energy cost per floor area',
              annual_energy_costs_per_pupil: 'Annual energy use per pupil',
              change_in_energy_since_last_year: 'Annual change in total energy use',
              holiday_usage_last_year: 'Cost of energy used in upcoming holiday last year'
            }
          },
          {
            name: 'Electricity Benchmarks',
            description: "These benchmarks compare schools' electricity consumption, including last year's consumption, recent and long term changes in consumption, baseload and performance against the school's target.",
            benchmarks: {
              annual_electricity_costs_per_pupil: 'Annual electricity use per pupil with savings potential',
              annual_electricity_out_of_hours_use: 'Electricity used out of school hours',
              baseload_per_pupil: 'Baseload per pupil',
              change_in_electricity_consumption_recent_school_weeks: 'Recent change in electricity use',
              change_in_electricity_holiday_consumption_previous_holiday: 'Change in electricity use between the last two holidays',
              change_in_electricity_holiday_consumption_previous_years_holiday: 'Change in electricity use between this holiday and the same holiday last year',
              change_in_electricity_since_last_year: 'Annual change in electricity use',
              electricity_consumption_during_holiday: 'Electricity use during current holiday',
              electricity_peak_kw_per_pupil: 'Peak school day electricity use',
              electricity_targets: 'Progress against electricity target',
              recent_change_in_baseload: 'Recent change in baseload',
              seasonal_baseload_variation: 'Seasonal baseload variation',
              weekday_baseload_variation: 'Weekday baseload variation',
              annual_change_in_electricity_out_of_hours_use: 'Annual change in electricity used out of school hours'
            }
          },
          {
            name: 'Gas and Storage Heater Benchmarks',
            description: "These benchmarks compare schools' gas or storage heater consumption, including last year's consumption, recent and long term changes in consumption, the standard of their heating control and performance against the school's target.",
            benchmarks: {
              annual_gas_out_of_hours_use: 'Gas used out of school hours',
              annual_heating_costs_per_floor_area: 'Annual heating cost per floor area with savings potential',
              annual_storage_heater_out_of_hours_use: 'Storage heaters used out of school hours',
              change_in_gas_consumption_recent_school_weeks: 'Recent change in gas use',
              change_in_gas_holiday_consumption_previous_holiday: 'Change in gas use between the last two holidays',
              change_in_gas_holiday_consumption_previous_years_holiday: 'Change in gas use between this holiday and the same holiday last year',
              change_in_gas_since_last_year: 'Annual change in gas use',
              change_in_storage_heaters_since_last_year: 'Annual change in storage heater',
              gas_consumption_during_holiday: 'Gas use during current holiday',
              gas_targets: 'Progress against gas target',
              heating_coming_on_too_early: 'Heating start time',
              heating_in_warm_weather: 'Heating used in warm weather',
              hot_water_efficiency: 'Hot Water Efficiency',
              storage_heater_consumption_during_holiday: 'Storage heater use during current holiday',
              thermostat_sensitivity: 'Annual saving through 1C reduction in thermostat temperature',
              thermostatic_control: 'Quality of thermostatic control',
              annual_change_in_gas_out_of_hours_use: 'Annual change in gas used out of school hours',
              annual_change_in_storage_heater_out_of_hours_use: 'Annual change in storage heater usage out of school hours'
            }
          },
          {
            name: 'Solar Benchmarks',
            description: "These benchmarks compare schools' solar PV production and the benefits of installing solar.",
            benchmarks: {
              change_in_solar_pv_since_last_year: 'Annual change in solar PV production and resulting CO2 savings',
              solar_pv_benefit_estimate: 'Benefit of solar PV installation'
            }
          }
        ]
      )
    end
  end
end
