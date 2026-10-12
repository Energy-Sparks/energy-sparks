# frozen_string_literal: true

module ArbitaryPeriodHelpers
  def generate_headers(fuel: false, unadjusted: false, urn: false, recent_holiday: false)
    [
      I18n.t('analytics.benchmarking.configuration.column_headings.school'),
      urn && 'URN',
      fuel && I18n.t('analytics.benchmarking.configuration.column_headings.fuel'),
      I18n.t('activerecord.attributes.school.activation_date'),
      recent_holiday && I18n.t('analytics.benchmarking.configuration.column_headings.most_recent_holiday'),
      unadjusted && I18n.t('comparisons.column_headings.previous_period_unadjusted'),
      I18n.t('comparisons.column_headings.previous_period'),
      I18n.t('comparisons.column_headings.current_period'),
      I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
      I18n.t('comparisons.column_headings.previous_period'),
      I18n.t('comparisons.column_headings.current_period'),
      I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
      I18n.t('comparisons.column_headings.previous_period'),
      I18n.t('comparisons.column_headings.current_period'),
      I18n.t('analytics.benchmarking.configuration.column_headings.change_pct')
    ].select(&:itself)
  end

  def generate_csv_header_groups(urn: false, fuel: false, recent_holiday: false, unadjusted: false)
    ['', ('' if urn), ('' if fuel), '', ('' if recent_holiday),
     'kWh', ('' if unadjusted), '', '', 'CO2 (kg)', '', '', '£', '', ''].compact
  end

  def column_groups
    ['',
     I18n.t('analytics.benchmarking.configuration.column_groups.kwh'),
     I18n.t('analytics.benchmarking.configuration.column_groups.co2_kg'),
     I18n.t('analytics.benchmarking.configuration.column_groups.gbp')].freeze
  end
end
