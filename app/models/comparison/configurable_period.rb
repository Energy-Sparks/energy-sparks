# == Schema Information
#
# Table name: configurable_periods
#
#  activation_date                               :date
#  custom_period_id                              :bigint(8)
#  electricity_current_period_co2                :float
#  electricity_current_period_gbp                :float
#  electricity_current_period_kwh                :float
#  electricity_custom_period_id                  :bigint(8)
#  electricity_previous_period_co2               :float
#  electricity_previous_period_gbp               :float
#  electricity_previous_period_kwh               :float
#  electricity_tariff_has_changed                :boolean
#  floor_area_changed                            :boolean
#  gas_current_period_co2                        :float
#  gas_current_period_gbp                        :float
#  gas_current_period_kwh                        :float
#  gas_custom_period_id                          :bigint(8)
#  gas_previous_period_co2                       :float
#  gas_previous_period_gbp                       :float
#  gas_previous_period_kwh                       :float
#  gas_previous_period_kwh_unadjusted            :float
#  gas_tariff_has_changed                        :boolean
#  id                                            :bigint(8)
#  pupils_changed                                :boolean
#  school_id                                     :bigint(8)
#  solar_type                                    :text
#  storage_heater_current_period_co2             :float
#  storage_heater_current_period_gbp             :float
#  storage_heater_current_period_kwh             :float
#  storage_heater_custom_period_id               :bigint(8)
#  storage_heater_previous_period_co2            :float
#  storage_heater_previous_period_gbp            :float
#  storage_heater_previous_period_kwh            :float
#  storage_heater_previous_period_kwh_unadjusted :float
#  storage_heater_tariff_has_changed             :boolean
#
class Comparison::ConfigurablePeriod < Comparison::View
  include MultipleFuelComparisonView
  include ArbitraryPeriodComparisonView
end
