# frozen_string_literal: true

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
# Indexes
#
#  index_change_in_solar_pv_since_last_years_on_school_id  (school_id) UNIQUE
#
module Comparison
  class ChangeInSolarPvSinceLastYear < Comparison::View
    scope :with_data, -> { where.not(previous_year_solar_pv_kwh: nil).where.not(current_year_solar_pv_kwh: nil) }
  end
end
