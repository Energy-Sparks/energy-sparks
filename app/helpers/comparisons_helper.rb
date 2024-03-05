module ComparisonsHelper
  def comparison_table_id(report)
    "#{report.key}-comparison-table"
  end

  def download_link(report, params)
    download_path = polymorphic_path([:comparisons, report.key.to_sym, :index], params: params.merge(format: :csv))
    link_to I18n.t('school_groups.download_as_csv'),
         download_path,
         class: 'btn btn-sm btn-outline-dark rounded-pill font-weight-bold',
         id: "#{report.key}-download-comparison-table-csv"
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
end
