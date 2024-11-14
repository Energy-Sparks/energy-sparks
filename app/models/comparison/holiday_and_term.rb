# == Schema Information
#
# Table name: comparison_holiday_and_terms
#
#  activation_date                               :date
#  electricity_current_period_co2                :float
#  electricity_current_period_end_date           :date
#  electricity_current_period_gbp                :float
#  electricity_current_period_kwh                :float
#  electricity_current_period_start_date         :date
#  electricity_current_period_type               :text
#  electricity_previous_period_co2               :float
#  electricity_previous_period_gbp               :float
#  electricity_previous_period_kwh               :float
#  electricity_tariff_has_changed                :boolean
#  electricity_truncated_current_period          :boolean
#  floor_area_changed                            :boolean
#  gas_current_period_co2                        :float
#  gas_current_period_end_date                   :date
#  gas_current_period_gbp                        :float
#  gas_current_period_kwh                        :float
#  gas_current_period_start_date                 :date
#  gas_current_period_type                       :text
#  gas_previous_period_co2                       :float
#  gas_previous_period_gbp                       :float
#  gas_previous_period_kwh                       :float
#  gas_previous_period_kwh_unadjusted            :float
#  gas_tariff_has_changed                        :boolean
#  gas_truncated_current_period                  :boolean
#  id                                            :bigint(8)
#  pupils_changed                                :boolean
#  school_id                                     :bigint(8)
#  solar_type                                    :text
#  storage_heater_current_period_co2             :float
#  storage_heater_current_period_end_date        :date
#  storage_heater_current_period_gbp             :float
#  storage_heater_current_period_kwh             :float
#  storage_heater_current_period_start_date      :date
#  storage_heater_current_period_type            :text
#  storage_heater_previous_period_co2            :float
#  storage_heater_previous_period_gbp            :float
#  storage_heater_previous_period_kwh            :float
#  storage_heater_previous_period_kwh_unadjusted :float
#  storage_heater_tariff_has_changed             :boolean
#  storage_heater_truncated_current_period       :boolean
#
# Indexes
#
#  index_comparison_holiday_and_terms_on_school_id  (school_id) UNIQUE
#
class Comparison::HolidayAndTerm < Comparison::View
  include MultipleFuelComparisonView
  include ArbitraryPeriodComparisonView
end
