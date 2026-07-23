# == Schema Information
#
# Table name: comparison_solar_generation_summaries
#
#  id                                  :bigint(8)
#  annual_electricity_kwh              :float
#  annual_exported_solar_pv_kwh        :float
#  annual_mains_consumed_kwh           :float
#  annual_solar_pv_consumed_onsite_kwh :float
#  annual_solar_pv_kwh                 :float
#  alert_generation_run_id             :bigint(8)
#  school_id                           :bigint(8)
#
# Indexes
#
#  index_comparison_solar_generation_summaries_on_school_id  (school_id) UNIQUE
#
class Comparison::SolarGenerationSummary < Comparison::View
  scope :with_data, -> { where.not(annual_solar_pv_kwh: nil) }
  scope :sort_default, -> { joins(:school).order('schools.name') }

  def self.report_headers
    [
      I18n.t('analytics.benchmarking.configuration.column_headings.school'),
      I18n.t('analytics.benchmarking.configuration.column_headings.solar_mains_consume'),
      I18n.t('analytics.benchmarking.configuration.column_headings.solar_generation'),
      I18n.t('analytics.benchmarking.configuration.column_headings.solar_self_consume'),
      I18n.t('analytics.benchmarking.configuration.column_headings.solar_export'),
      I18n.t('analytics.benchmarking.configuration.column_headings.solar_mains_onsite')
    ]
  end
end
