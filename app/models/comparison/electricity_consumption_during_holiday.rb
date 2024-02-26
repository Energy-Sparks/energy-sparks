# frozen_string_literal: true

# == Schema Information
#
# Table name: electricity_consumption_during_holidays
#
#  alert_generation_run_id     :bigint(8)
#  holiday_name                :text
#  holiday_projected_usage_gbp :float
#  holiday_usage_to_date_gbp   :float
#  id                          :bigint(8)
#  school_id                   :bigint(8)
#
module Comparison
  class ElectricityConsumptionDuringHoliday < Comparison::View
  end
end
