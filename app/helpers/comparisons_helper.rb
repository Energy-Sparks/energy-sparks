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

  def comparison_page_exists?(key)
    Object.const_defined?("Comparisons::#{key.to_s.camelcase}Controller")
  end

  def holiday_name(type, start_date, end_date, partial: false)
    year = if start_date.year == end_date.year
             start_date.year.to_s
           else
             "#{start_date.year}/#{end_date.year}"
           end
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
