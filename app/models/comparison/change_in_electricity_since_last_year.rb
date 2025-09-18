# == Schema Information
#
# Table name: comparison_change_in_electricity_since_last_years
#
#  current_year_electricity_co2  :float
#  current_year_electricity_gbp  :float
#  current_year_electricity_kwh  :float
#  id                            :bigint(8)
#  previous_year_electricity_co2 :float
#  previous_year_electricity_gbp :float
#  previous_year_electricity_kwh :float
#  school_id                     :bigint(8)
#  solar_type                    :text
#
# Indexes
#
#  idx_on_school_id_14ce133c88  (school_id) UNIQUE
#
class Comparison::ChangeInElectricitySinceLastYear < Comparison::View
  scope :with_data, -> { where('previous_year_electricity_kwh IS NOT NULL AND current_year_electricity_kwh IS NOT NULL') }

  def self.default_header_groups
    [
      { label: '',
        headers: [I18n.t('analytics.benchmarking.configuration.column_headings.school')] },
      { label: I18n.t('analytics.benchmarking.configuration.column_groups.kwh'),
        headers: [
          I18n.t('analytics.benchmarking.configuration.column_headings.previous_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.last_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.change_pct')
        ] },
      { label: I18n.t('analytics.benchmarking.configuration.column_groups.co2_kg'),
        headers: [
          I18n.t('analytics.benchmarking.configuration.column_headings.previous_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.last_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.change_pct')
        ] },
      { label: I18n.t('analytics.benchmarking.configuration.column_groups.gbp'),
        headers: [
          I18n.t('analytics.benchmarking.configuration.column_headings.previous_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.last_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.change_pct')
        ] },
      { label: I18n.t('analytics.benchmarking.configuration.column_groups.solar_self_consumption'),
        headers: [I18n.t('analytics.benchmarking.configuration.column_headings.estimated')] }
    ]
  end
end
