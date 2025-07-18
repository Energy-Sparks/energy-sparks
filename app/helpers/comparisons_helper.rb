# frozen_string_literal: true

module ComparisonsHelper
  def comparison_table_id(report, table_name)
    "#{report.key}-#{table_name}"
  end

  def comparison_report_path(report, params)
    if report.reporting_period == 'custom'
      # it seems since the route doesn't use a resource polymorphic_path doesn't work
      comparisons_configurable_period_path(key: report.key, params: params)
    else
      path = [:comparisons, report.key.to_sym]
      # If the key is plural then rails routing works slightly  differently, so exclude :index component
      path << :index if report.key.singularize == report.key
      begin
        polymorphic_path(path, params: params)
      rescue NoMethodError
        nil
      end
    end
  end

  def download_link(report, table_name, params)
    download_params = params.merge(table_name: table_name, format: :csv)
    download_path = comparison_report_path(report, download_params)
    link_to I18n.t('school_groups.download_as_csv'),
            download_path,
            class: 'btn btn-sm btn-default',
            id: "#{report.key}-#{table_name}-download"
  end

  def percent_change(base, new_val, to_nil_if_sum_zero = false)
    EnergySparks::Calculator.percent_change(base, new_val, to_nil_if_sum_zero)
  end

  def sum_data(data, to_nil_if_sum_zero = false)
    EnergySparks::Calculator.sum_data(data, to_nil_if_sum_zero)
  end

  def sum_if_complete(previous_year_values, current_year_values)
    EnergySparks::Calculator.sum_if_complete(previous_year_values, current_year_values)
  end

  def gas_or_electricity_data_stale?(result, window = 90)
    threshold = Time.zone.today - window
    (result.school.has_electricity? && result.school.configuration.meter_end_date(:electricity).present? && result.school.configuration.meter_end_date(:electricity).before?(threshold)) ||
      (result.school.has_gas? && result.school.configuration.meter_end_date(:gas).present? && result.school.configuration.meter_end_date(:gas).before?(threshold))
  end

  def holiday_name(type, start_date, end_date, partial: false)
    return '' if type.nil?

    year = start_date.year.to_s
    year += "/#{end_date.year}" if start_date.year != end_date.year
    holiday = I18n.t('analytics.holidays')[type.to_sym]
    partial = partial ? " #{I18n.t('advice_pages.tables.labels.partial')}" : ''
    "#{I18n.t('analytics.holiday_year', holiday: holiday, year: year)}#{partial}"
  end

  def csv_colgroups(colgroups)
    colgroups.flat_map do |group|
      [group[:label]] + Array.new(group.fetch(:colspan, 1) - 1, '')
    end
  end
end
