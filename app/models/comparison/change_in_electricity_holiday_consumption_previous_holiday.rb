# frozen_string_literal: true

# == Schema Information
#
# Table name: change_in_electricity_holiday_consumption_previous_holidays
#
#  alert_generation_run_id    :bigint(8)
#  current_period_end_date    :date
#  current_period_start_date  :date
#  current_period_type        :text
#  difference_gbpcurrent      :float
#  difference_kwh             :float
#  difference_percent         :float
#  id                         :bigint(8)
#  previous_period_end_date   :date
#  previous_period_start_date :date
#  previous_period_type       :text
#  pupils_changed             :boolean
#  school_id                  :bigint(8)
#  tariff_has_changed         :boolean
#  truncated_current_period   :boolean
#
module Comparison
  class ChangeInElectricityHolidayConsumptionPreviousHoliday < Comparison::View
  end
end
