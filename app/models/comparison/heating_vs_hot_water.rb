# == Schema Information
#
# Table name: comparison_heating_vs_hot_waters
#
#  estimated_hot_water_gas_kwh    :float
#  estimated_hot_water_percentage :float
#  id                             :bigint(8)
#  last_year_gas_kwh              :float
#  school_id                      :bigint(8)
#
# Indexes
#
#  index_comparison_heating_vs_hot_waters_on_school_id  (school_id) UNIQUE
#
class Comparison::HeatingVsHotWater < Comparison::View
end
