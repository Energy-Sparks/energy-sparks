# == Schema Information
#
# Table name: change_in_electricity_since_last_years
#
#  current_year_electricity_co2  :float
#  current_year_electricity_gbp  :float
#  current_year_electricity_kwh  :float
#  id                            :bigint(8)
#  previous_year_electricity_co2 :float
#  previous_year_electricity_gbp :float
#  previous_year_electricity_kwh :float
#  school_id                     :bigint(8)
#  solar_type                    :text
#
class Comparison::ChangeInElectricitySinceLastYear < Comparison::View
end
