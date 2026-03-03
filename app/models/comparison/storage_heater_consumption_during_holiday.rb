# == Schema Information
#
# Table name: comparison_storage_heater_consumption_during_holidays
#
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
#  idx_on_school_id_43b0326934  (school_id) UNIQUE
#
class Comparison::StorageHeaterConsumptionDuringHoliday < Comparison::View
end
