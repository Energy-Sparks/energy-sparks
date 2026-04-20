# frozen_string_literal: true

# == Schema Information
#
# Table name: comparison_change_in_electricity_holiday_consumption_previous_years_holidays
#
#  id                         :bigint
#  current_period_end_date    :date
#  current_period_start_date  :date
#  current_period_type        :text
#  difference_gbpcurrent      :float
#  difference_kwh             :float
#  difference_percent         :float
#  previous_period_end_date   :date
#  previous_period_start_date :date
#  previous_period_type       :text
#  pupils_changed             :boolean
#  tariff_has_changed         :boolean
#  truncated_current_period   :boolean
#  alert_generation_run_id    :bigint
#  school_id                  :bigint
#
# Indexes
#
#  idx_on_school_id_dd11f128c1  (school_id) UNIQUE
#
module Comparison
  class ChangeInElectricityHolidayConsumptionPreviousYearsHoliday < Comparison::View
  end
end
