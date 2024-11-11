# == Schema Information
#
# Table name: annual_change_in_storage_heater_out_of_hours_uses
#
#  alert_generation_run_id           :bigint(8)
#  economic_tariff_changed_this_year :boolean
#  id                                :bigint(8)
#  out_of_hours_co2                  :float
#  out_of_hours_gbpcurrent           :float
#  out_of_hours_kwh                  :float
#  previous_out_of_hours_co2         :float
#  previous_out_of_hours_gbpcurrent  :float
#  previous_out_of_hours_kwh         :float
#  school_id                         :bigint(8)
#
# Indexes
#
#  idx_on_school_id_8d431723c5  (school_id) UNIQUE
#
class Comparison::AnnualChangeInStorageHeaterOutOfHoursUse < Comparison::View
end
