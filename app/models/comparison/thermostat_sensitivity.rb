# == Schema Information
#
# Table name: thermostat_sensitivities
#
#  alert_generation_run_id      :bigint(8)
#  annual_saving_1_C_change_gbp :float
#  id                           :bigint(8)
#  school_id                    :bigint(8)
#
class Comparison::ThermostatSensitivity < Comparison::View
  scope :with_data, -> { where('"annual_saving_1_C_change_gbp" IS NOT NULL and "annual_saving_1_C_change_gbp" > 0.0') }
  scope :sort_default, -> { order(annual_saving_1_C_change_gbp: :desc) }
end
