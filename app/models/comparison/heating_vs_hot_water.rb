# == Schema Information
#
# Table name: heating_vs_hot_waters
#
#  estimated_hot_water_gas_kwh    :float
#  estimated_hot_water_percentage :float
#  id                             :bigint(8)
#  last_year_gas_kwh              :float
#  school_id                      :bigint(8)
#
class Comparison::HeatingVsHotWater < Comparison::View
end
