# == Schema Information
#
# Table name: comparison_thermostat_sensitivities
#
#  id                           :bigint
#  annual_saving_1_C_change_gbp :float
#  alert_generation_run_id      :bigint
#  school_id                    :bigint
#
# Indexes
#
#  index_comparison_thermostat_sensitivities_on_school_id  (school_id) UNIQUE
#
class Comparison::ThermostatSensitivity < Comparison::View
  scope :with_data, -> { where('"annual_saving_1_C_change_gbp" IS NOT NULL and "annual_saving_1_C_change_gbp" > 0.0') }
  scope :sort_default, -> { order(annual_saving_1_C_change_gbp: :desc) }
end
