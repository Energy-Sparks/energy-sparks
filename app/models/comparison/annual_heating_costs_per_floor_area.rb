# == Schema Information
#
# Table name: comparison_annual_heating_costs_per_floor_areas
#
#  electricity_economic_tariff_changed_this_year              :boolean
#  gas_economic_tariff_changed_this_year                      :boolean
#  gas_last_year_co2                                          :float
#  gas_last_year_gbp                                          :float
#  gas_last_year_kwh                                          :float
#  id                                                         :bigint(8)
#  one_year_gas_per_floor_area_co2                            :float
#  one_year_gas_per_floor_area_gbp                            :float
#  one_year_gas_per_floor_area_kwh                            :float
#  one_year_gas_saving_versus_exemplar_gbpcurrent             :float
#  one_year_storage_heaters_per_floor_area_co2                :float
#  one_year_storage_heaters_per_floor_area_gbp                :float
#  one_year_storage_heaters_per_floor_area_kwh                :float
#  one_year_storage_heaters_saving_versus_exemplar_gbpcurrent :float
#  school_id                                                  :bigint(8)
#  storage_heaters_last_year_co2                              :float
#  storage_heaters_last_year_gbp                              :float
#  storage_heaters_last_year_kwh                              :float
#
# Indexes
#
#  idx_on_school_id_80be77e6f6  (school_id) UNIQUE
#
class Comparison::AnnualHeatingCostsPerFloorArea < Comparison::View
  scope :with_data, -> { where.not(gas_last_year_kwh: nil) }
  scope :sort_default, -> { order(one_year_gas_per_floor_area_kwh: :desc) }
end
