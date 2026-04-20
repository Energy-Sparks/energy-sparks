# == Schema Information
#
# Table name: comparison_holiday_usage_last_years
#
#  id                                               :bigint
#  holiday_start_date                               :date
#  last_year_holiday_electricity_gbp                :float
#  last_year_holiday_electricity_gbpcurrent         :float
#  last_year_holiday_electricity_kwh_per_floor_area :float
#  last_year_holiday_end_date                       :date
#  last_year_holiday_gas_gbp                        :float
#  last_year_holiday_gas_gbpcurrent                 :float
#  last_year_holiday_gas_kwh_per_floor_area         :float
#  last_year_holiday_start_date                     :date
#  last_year_holiday_type                           :text
#  alert_generation_run_id                          :bigint
#  school_id                                        :bigint
#
# Indexes
#
#  index_comparison_holiday_usage_last_years_on_school_id  (school_id) UNIQUE
#
class Comparison::HolidayUsageLastYear < Comparison::View
  scope :with_data, -> { where.not(last_year_holiday_gas_gbp: nil) }
  scope :sort_default, -> { order(last_year_holiday_gas_gbp: :desc) }
end
