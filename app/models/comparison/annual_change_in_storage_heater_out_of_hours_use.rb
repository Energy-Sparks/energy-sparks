# == Schema Information
#
# Table name: comparison_annual_change_in_storage_heater_out_of_hours_uses
#
#  id                                :bigint
#  economic_tariff_changed_this_year :boolean
#  out_of_hours_co2                  :float
#  out_of_hours_gbpcurrent           :float
#  out_of_hours_kwh                  :float
#  previous_out_of_hours_co2         :float
#  previous_out_of_hours_gbpcurrent  :float
#  previous_out_of_hours_kwh         :float
#  alert_generation_run_id           :bigint
#  school_id                         :bigint
#
# Indexes
#
#  idx_on_school_id_d34348aa11  (school_id) UNIQUE
#
class Comparison::AnnualChangeInStorageHeaterOutOfHoursUse < Comparison::View
end
