# frozen_string_literal: true

module ComparisonsHelper
  def comparison_table_id(report, table_name)
    "#{report.key}-#{table_name}"
  end

  def download_link(report, table_name, params)
    path = [:comparisons, report.key.to_sym]
    # If the key is plural then rails routing works slightly
    # differently, so exclude :index component
    path << :index if report.key.singularize == report.key
    download_path = polymorphic_path(path, params: params.merge(table_name: table_name, format: :csv))

    link_to I18n.t('school_groups.download_as_csv'),
            download_path,
            class: 'btn btn-sm btn-outline-dark rounded-pill font-weight-bold',
            id: "#{report.key}-#{table_name}-download"
  end

  # Calculate percentage change across two values or sum of values in two arrays
  def percent_change(base, new_val, to_nil_if_sum_zero = false)
    return nil if to_nil_if_sum_zero && sum_data(base) == 0.0
    return 0.0 if sum_data(base) == 0.0

    change = (sum_data(new_val) - sum_data(base)) / sum_data(base)
    to_nil_if_sum_zero && change == 0.0 ? nil : change
  end

  def sum_data(data, to_nil_if_sum_zero = false)
    data = Array(data)
    data.map! { |value| value || 0.0 } # create array 1st to avoid statsample map/sum bug
    val = data.sum
    to_nil_if_sum_zero && val == 0.0 ? nil : val
  end

  # Accepts 2 arrays of kwh, co2 or £ values.
  # Expects first 2 values of each array to be the electricity and gas values
  # Remainder of array can be storage heater and solar
  #
  # Only sums +previous_year_values+ if:
  #
  # there are values for both electricity and gas in years
  # electricity (or gas) is missing in both years
  #
  # Returns nil if there's no value for previous year, but there is for the current
  # year. As this indicates that the data coverage is incomplete and summing the values
  # would produce a misleading figure.
  #
  # Storage heater values are (presumably) not checked because these are based on
  # electricity data and will be missing if the electricity is missing.
  #
  # Solar is not checked as panels may not have been installed until this year.
  #
  def sum_if_complete(previous_year_values, current_year_values)
    eg_prev = previous_year_values[0..1].map(&:nil?)
    eg_curr = current_year_values[0..1].map(&:nil?)

    return nil if eg_prev != eg_curr

    sum_data(previous_year_values)
  end

  def comparison_page_exists?(key)
    Object.const_defined?("Comparisons::#{key.to_s.camelcase}Controller")
  end

  def holiday_name(type, start_date, end_date, partial: false)
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
