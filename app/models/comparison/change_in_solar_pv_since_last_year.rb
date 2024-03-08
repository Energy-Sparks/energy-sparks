# == Schema Information
#
# Table name: change_in_solar_pv_since_last_years
#
#  current_year_solar_pv_co2  :float
#  current_year_solar_pv_kwh  :float
#  id                         :bigint(8)
#  previous_year_solar_pv_co2 :float
#  previous_year_solar_pv_kwh :float
#  school_id                  :bigint(8)
#  solar_type                 :text
#
class Comparison::ChangeInSolarPvSinceLastYear < Comparison::View
  scope :with_data, -> { where.not(previous_year_solar_pv_kwh: nil) }
end
