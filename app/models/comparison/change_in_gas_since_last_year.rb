# == Schema Information
#
# Table name: change_in_gas_since_last_years
#
#  alert_generation_run_id                :bigint(8)
#  current_year_co2                       :float
#  current_year_gbp                       :float
#  current_year_kwh                       :float
#  id                                     :bigint(8)
#  previous_year_co2                      :float
#  previous_year_gbp                      :float
#  previous_year_kwh                      :float
#  school_id                              :bigint(8)
#  temperature_adjusted_percent           :float
#  temperature_adjusted_previous_year_kwh :float
#
class Comparison::ChangeInGasSinceLastYear < Comparison::View
end
