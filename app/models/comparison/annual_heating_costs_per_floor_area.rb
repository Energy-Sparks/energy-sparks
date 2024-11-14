# == Schema Information
#
# Table name: comparison_annual_heating_costs_per_floor_areas
#
#  gas_economic_tariff_changed_this_year      :boolean
#  gas_last_year_co2                          :float
#  id                                         :bigint(8)
#  last_year_co2                              :float
#  last_year_gbp                              :float
#  last_year_kwh                              :float
#  one_year_gas_per_floor_area_normalised_gbp :float
#  one_year_saving_versus_exemplar_gbpcurrent :float
#  school_id                                  :bigint(8)
#
# Indexes
#
#  idx_on_school_id_80be77e6f6  (school_id) UNIQUE
#
class Comparison::AnnualHeatingCostsPerFloorArea < Comparison::View
  scope :with_data, -> { where.not(gas_last_year_co2: nil) }
  scope :sort_default, -> { order(one_year_gas_per_floor_area_normalised_gbp: :desc) }
end
