module Comparisons
  class HeatSaverMarch2024Controller < BaseController
    def index
      @electricity_headers = electricity_headers
      @electricity_colgroups = electricity_colgroups
      @heating_colgroups = heating_colgroups
      @heating_headers = heating_headers
      super
    end

    private

    def headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('analytics.benchmarking.configuration.column_headings.fuel'),
        t('activerecord.attributes.school.activation_date'),
        t('comparisons.column_headings.previous_period'),
        t('comparisons.column_headings.current_period'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('comparisons.column_headings.previous_period'),
        t('comparisons.column_headings.current_period'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('comparisons.column_headings.previous_period'),
        t('comparisons.column_headings.current_period'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
      ]
    end

    def electricity_headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('activerecord.attributes.school.activation_date'),
        t('comparisons.column_headings.previous_period'),
        t('comparisons.column_headings.current_period'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('comparisons.column_headings.previous_period'),
        t('comparisons.column_headings.current_period'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('comparisons.column_headings.previous_period'),
        t('comparisons.column_headings.current_period'),
        t('analytics.benchmarking.configuration.column_headings.change_pct')
      ]
    end

    def heating_headers
      [
        t('analytics.benchmarking.configuration.column_headings.school'),
        t('activerecord.attributes.school.activation_date'),
        t('comparisons.column_headings.previous_period_unadjusted'),
        t('comparisons.column_headings.previous_period'),
        t('comparisons.column_headings.current_period'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('comparisons.column_headings.previous_period'),
        t('comparisons.column_headings.current_period'),
        t('analytics.benchmarking.configuration.column_headings.change_pct'),
        t('comparisons.column_headings.previous_period'),
        t('comparisons.column_headings.current_period'),
        t('analytics.benchmarking.configuration.column_headings.change_pct')
      ]
    end

    def colgroups
      [
        { label: '', colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.kwh'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.co2_kg'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.gbp'), colspan: 3 }
      ]
    end

    def electricity_colgroups
      [
        { label: '', colspan: 2 },
        { label: t('analytics.benchmarking.configuration.column_groups.kwh'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.co2_kg'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.gbp'), colspan: 3 }
      ]
    end

    def heating_colgroups
      [
        { label: '', colspan: 2 },
        { label: t('analytics.benchmarking.configuration.column_groups.kwh'), colspan: 4 },
        { label: t('analytics.benchmarking.configuration.column_groups.co2_kg'), colspan: 3 },
        { label: t('analytics.benchmarking.configuration.column_groups.gbp'), colspan: 3 }
      ]
    end

    def key
      :heat_saver_march_2024
    end

    def advice_page_key
      :total_energy_use
    end

    def load_data
      Comparison::HeatSaverMarch2024.for_schools(@schools).where_any_present([:electricity_previous_period_kwh, :gas_previous_period_kwh, :storage_heater_current_period_kwh]).order('schools.name ASC')
    end

    def table_names
      [:total, :electricity, :gas, :storage_heater]
    end

    def create_charts(_results)
      []
      # change as appropriate!
      # create_single_number_chart(results, name, multiplier, series_name, y_axis_label)
    end
  end
end
