# == Schema Information
#
# Table name: comparison_annual_energy_costs_per_units
#
#  electricity_economic_tariff_changed_this_year :boolean
#  floor_area                                    :float
#  gas_economic_tariff_changed_this_year         :boolean
#  id                                            :bigint(8)
#  one_year_electricity_per_floor_area_co2       :float
#  one_year_electricity_per_floor_area_gbp       :float
#  one_year_electricity_per_floor_area_kwh       :float
#  one_year_electricity_per_pupil_co2            :float
#  one_year_electricity_per_pupil_gbp            :float
#  one_year_electricity_per_pupil_kwh            :float
#  one_year_gas_per_floor_area_co2               :float
#  one_year_gas_per_floor_area_gbp               :float
#  one_year_gas_per_floor_area_kwh               :float
#  one_year_gas_per_pupil_co2                    :float
#  one_year_gas_per_pupil_gbp                    :float
#  one_year_gas_per_pupil_kwh                    :float
#  one_year_storage_heater_per_floor_area_co2    :float
#  one_year_storage_heater_per_floor_area_gbp    :float
#  one_year_storage_heater_per_floor_area_kwh    :float
#  one_year_storage_heater_per_pupil_co2         :float
#  one_year_storage_heater_per_pupil_gbp         :float
#  one_year_storage_heater_per_pupil_kwh         :float
#  pupils                                        :float
#  school_id                                     :bigint(8)
#
# Indexes
#
#  index_comparison_annual_energy_costs_per_units_on_school_id  (school_id) UNIQUE
#
class Comparison::AnnualEnergyCostsPerUnit < Comparison::View
  def pupil_kwhs
    [one_year_electricity_per_pupil_kwh, one_year_gas_per_pupil_kwh, one_year_storage_heater_per_pupil_kwh]
  end

  def pupil_costs
    [one_year_electricity_per_pupil_gbp, one_year_gas_per_pupil_gbp, one_year_storage_heater_per_pupil_gbp]
  end

  def pupil_co2s
    [one_year_electricity_per_pupil_co2, one_year_gas_per_pupil_co2, one_year_storage_heater_per_pupil_co2]
  end

  def floor_area_kwhs
    [one_year_electricity_per_floor_area_kwh, one_year_gas_per_floor_area_kwh, one_year_storage_heater_per_floor_area_kwh]
  end

  def floor_area_costs
    [one_year_electricity_per_floor_area_gbp, one_year_gas_per_floor_area_gbp, one_year_storage_heater_per_floor_area_gbp]
  end

  def floor_area_co2s
    [one_year_electricity_per_floor_area_co2, one_year_gas_per_floor_area_co2, one_year_storage_heater_per_floor_area_co2]
  end
end
