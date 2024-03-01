# frozen_string_literal: true

# == Schema Information
#
# Table name: change_in_electricity_holiday_consumption_previous_holidays
#
#  alert_generation_run_id  :bigint(8)
#  difference_gbpcurrent    :float
#  difference_kwh           :float
#  difference_percent       :float
#  id                       :bigint(8)
#  name_of_current_period   :text
#  name_of_previous_period  :text
#  pupils_changed           :boolean
#  school_id                :bigint(8)
#  tariff_has_changed       :boolean
#  truncated_current_period :boolean
#
module Comparison
  class ChangeInElectricityHolidayConsumptionPreviousHoliday < Comparison::View
  end
end
