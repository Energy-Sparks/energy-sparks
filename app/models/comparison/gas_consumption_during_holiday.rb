# == Schema Information
#
# Table name: comparison_gas_consumption_during_holidays
#
#  alert_generation_run_id     :bigint(8)
#  holiday_end_date            :date
#  holiday_projected_usage_gbp :float
#  holiday_start_date          :date
#  holiday_type                :text
#  holiday_usage_to_date_gbp   :float
#  id                          :bigint(8)
#  school_id                   :bigint(8)
#
# Indexes
#
#  index_comparison_gas_consumption_during_holidays_on_school_id  (school_id) UNIQUE
#
class Comparison::GasConsumptionDuringHoliday < Comparison::View
end
