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
# Indexes
#
#  index_change_in_electricity_since_last_years_on_school_id  (school_id) UNIQUE
#
class Comparison::ChangeInElectricitySinceLastYear < Comparison::View
  scope :with_data, -> { where('previous_year_electricity_kwh IS NOT NULL AND current_year_electricity_kwh IS NOT NULL') }
end
