# == Schema Information
#
# Table name: change_in_storage_heaters_since_last_years
#
#  alert_generation_run_id                :bigint(8)
#  current_year_gas_co2                   :float
#  current_year_gas_gbp                   :float
#  current_year_gas_kwh                   :float
#  id                                     :bigint(8)
#  previous_year_gas_co2                  :float
#  previous_year_gas_gbp                  :float
#  previous_year_gas_kwh                  :float
#  school_id                              :bigint(8)
#  temperature_adjusted_percent           :float
#  temperature_adjusted_previous_year_kwh :float
#
class Comparison::ChangeInStorageHeatersSinceLastYear < Comparison::View
end
