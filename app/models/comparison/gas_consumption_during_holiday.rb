# == Schema Information
#
# Table name: gas_consumption_during_holidays
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
class Comparison::GasConsumptionDuringHoliday < Comparison::View
end
