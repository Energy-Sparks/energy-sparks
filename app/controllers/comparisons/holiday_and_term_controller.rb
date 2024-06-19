module Comparisons
  class HolidayAndTermController < Shared::ArbitraryPeriodController
    private

    def set_headers(include_previous_period_unadjusted: true)
      super()
      @include_previous_period_unadjusted = include_previous_period_unadjusted
      @electricity_colgroups = colgroups(fuel: false, holiday_name: true)
      @electricity_headers = headers(fuel: false, holiday_name: true)
      @heating_colgroups = colgroups(fuel: false, previous_period_unadjusted: @include_previous_period_unadjusted, holiday_name: true)
      @heating_headers = headers(fuel: false, previous_period_unadjusted: @include_previous_period_unadjusted, holiday_name: true)
      @period_type_string = I18n.t('comparisons.period_types.periods')
    end

    def headers(fuel: true, previous_period_unadjusted: false, holiday_name: false)
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        fuel && t('analytics.benchmarking.configuration.column_headings.fuel'),
        t('activerecord.attributes.school.activation_date'),
        holiday_name && t('analytics.benchmarking.configuration.column_headings.most_recent_holiday'),
        previous_period_unadjusted && t('comparisons.column_headings.previous_period_unadjusted'),
        t('comparisons.column_headings.previous_period'),
        t('comparisons.column_headings.current_period'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('comparisons.column_headings.previous_period'),
        t('comparisons.column_headings.current_period'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('comparisons.column_headings.previous_period'),
        t('comparisons.column_headings.current_period'),
        t('analytics.benchmarking.configuration.column_headings.change_pct')
      ].select(&:itself)
    end

    def colgroups(fuel: true, previous_period_unadjusted: false, holiday_name: false)
      [
        { label: '', colspan: fuel || holiday_name ? 3 : 2 },
        { label: t('analytics.benchmarking.configuration.column_groups.kwh'),
          colspan: previous_period_unadjusted ? 4 : 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.co2_kg'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.gbp'), colspan: 3 }
      ]
    end

    def key
      :holiday_and_term
    end

    def load_data
      Comparison::HolidayAndTerm.for_schools(@schools).with_data_for_previous_period.by_total_percentage_change
    end
  end
end
