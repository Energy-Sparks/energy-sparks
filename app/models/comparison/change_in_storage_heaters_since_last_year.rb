# == Schema Information
#
# Table name: comparison_change_in_storage_heaters_since_last_years
#
#  id                                     :bigint(8)
#  current_year_co2                       :float
#  current_year_gbp                       :float
#  current_year_kwh                       :float
#  previous_year_co2                      :float
#  previous_year_gbp                      :float
#  previous_year_kwh                      :float
#  temperature_adjusted_percent           :float
#  temperature_adjusted_previous_year_kwh :float
#  alert_generation_run_id                :bigint(8)
#  school_id                              :bigint(8)
#
# Indexes
#
#  idx_on_school_id_5808ed6062  (school_id) UNIQUE
#
class Comparison::ChangeInStorageHeatersSinceLastYear < Comparison::View
end
