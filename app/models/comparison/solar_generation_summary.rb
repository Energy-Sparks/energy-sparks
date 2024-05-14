# == Schema Information
#
# Table name: solar_generation_summaries
#
#  alert_generation_run_id             :bigint(8)
#  annual_electricity_kwh              :float
#  annual_exported_solar_pv_kwh        :float
#  annual_mains_consumed_kwh           :float
#  annual_solar_pv_consumed_onsite_kwh :float
#  annual_solar_pv_kwh                 :float
#  id                                  :bigint(8)
#  school_id                           :bigint(8)
#
class Comparison::SolarGenerationSummary < Comparison::View
  scope :with_data, -> { where.not(annual_solar_pv_kwh: nil) }
  scope :sort_default, -> { joins(:school).order('schools.name') }
end
