# == Schema Information
#
# Table name: holiday_usage_last_years
#
#  alert_generation_run_id                          :bigint(8)
#  id                                               :bigint(8)
#  last_year_holiday_electricity_gbp                :float
#  last_year_holiday_electricity_gbpcurrent         :float
#  last_year_holiday_electricity_kwh_per_floor_area :float
#  last_year_holiday_gas_gbp                        :float
#  last_year_holiday_gas_gbpcurrent                 :float
#  last_year_holiday_gas_kwh_per_floor_area         :float
#  name_of_last_year_holiday                        :text
#  school_id                                        :bigint(8)
#
class Comparison::HolidayUsageLastYear < Comparison::View
  scope :with_data, -> { where.not(last_year_holiday_gas_gbp: nil) }
  scope :sort_default, -> { order(last_year_holiday_gas_gbp: :desc) }
end
