# == Schema Information
#
# Table name: comparison_heating_in_warm_weathers
#
#  id                                            :bigint(8)
#  percent_of_annual_heating                     :float
#  school_id                                     :bigint(8)
#  warm_weather_heating_days_all_days_co2        :float
#  warm_weather_heating_days_all_days_days       :float
#  warm_weather_heating_days_all_days_gbpcurrent :float
#  warm_weather_heating_days_all_days_kwh        :float
#
# Indexes
#
#  index_comparison_heating_in_warm_weathers_on_school_id  (school_id) UNIQUE
#
class Comparison::HeatingInWarmWeather < Comparison::View
  scope :with_data, -> { where.not(percent_of_annual_heating: nil) }
  scope :sort_default, -> { order(percent_of_annual_heating: :desc) }
end
