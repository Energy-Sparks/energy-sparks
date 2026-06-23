CSV.generate do |csv|
  csv << csv_colgroups(@colgroups)
  csv << @headers
  @results.each do |result|
   csv << [
        result.school.name,
        format_unit(result.previous_year_kwh, Float, true, :benchmark),
        format_unit(result.current_year_kwh, Float, true, :benchmark),
        format_csv_percent_change(result.previous_year_kwh, result.current_year_kwh),
        format_unit(result.previous_year_co2, Float, true, :benchmark),
        format_unit(result.current_year_co2, Float, true, :benchmark),
        format_csv_percent_change(result.previous_year_co2, result.current_year_co2),
        format_unit(result.previous_year_gbp, Float, true, :benchmark),
        format_unit(result.current_year_gbp, Float, true, :benchmark),
        format_csv_percent_change(result.previous_year_gbp, result.current_year_gbp),
        result.solar_type == 'synthetic' ?
          t('common.labels.yes_label') : t('common.labels.no_label')
      ]
  end
end.html_safe
