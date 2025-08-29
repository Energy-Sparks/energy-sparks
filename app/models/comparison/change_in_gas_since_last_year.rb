# == Schema Information
#
# Table name: comparison_change_in_gas_since_last_years
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
# Indexes
#
#  index_comparison_change_in_gas_since_last_years_on_school_id  (school_id) UNIQUE
#
class Comparison::ChangeInGasSinceLastYear < Comparison::View
  def self.default_header_groups
    [
      { label: '',
        headers: [I18n.t('analytics.benchmarking.configuration.column_headings.school')] },
      { label: I18n.t('analytics.benchmarking.configuration.column_groups.kwh'),
        headers: [
          I18n.t('analytics.benchmarking.configuration.column_headings.previous_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.previous_year_temperature_adjusted'),
          I18n.t('analytics.benchmarking.configuration.column_headings.last_year')
        ] },
      { label: I18n.t('analytics.benchmarking.configuration.column_groups.co2_kg'),
        headers: [
          I18n.t('analytics.benchmarking.configuration.column_headings.previous_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.last_year'),
        ] },
      { label: I18n.t('analytics.benchmarking.configuration.column_groups.gbp'),
        headers: [
          I18n.t('analytics.benchmarking.configuration.column_headings.previous_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.last_year'),
        ] },
      { label: I18n.t('analytics.benchmarking.configuration.column_groups.percent_changed'),
        headers: [
          I18n.t('analytics.benchmarking.configuration.column_headings.unadjusted_kwh'),
          I18n.t('analytics.benchmarking.configuration.column_headings.temperature_adjusted_kwh'),
        ] }
    ]
  end
end
