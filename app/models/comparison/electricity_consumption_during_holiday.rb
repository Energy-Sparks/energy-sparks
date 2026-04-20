# frozen_string_literal: true

# == Schema Information
#
# Table name: comparison_electricity_consumption_during_holidays
#
#  id                          :bigint
#  holiday_end_date            :date
#  holiday_projected_usage_gbp :float
#  holiday_start_date          :date
#  holiday_type                :text
#  holiday_usage_to_date_gbp   :float
#  school_id                   :bigint
#
# Indexes
#
#  idx_on_school_id_f87dfdb857  (school_id) UNIQUE
#
module Comparison
  class ElectricityConsumptionDuringHoliday < Comparison::View
  end
end
