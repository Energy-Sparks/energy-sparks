# == Schema Information
#
# Table name: comparison_change_in_gas_holiday_consumption_previous_years_holidays
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
# Indexes
#
#  idx_on_school_id_a2d5e09d4c  (school_id) UNIQUE
#
class Comparison::ChangeInGasHolidayConsumptionPreviousYearsHoliday < Comparison::View
end
