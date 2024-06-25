CSV.generate do |csv|
  csv << csv_colgroups(@colgroups)
  csv << @headers
  @results.each do |result|
   csv << [
        result.school.name,
        format_unit(result.previous_year_electricity_kwh, Float, true, :benchmark),
        format_unit(result.current_year_electricity_kwh, Float, true, :benchmark),
        format_unit(percent_change(result.previous_year_electricity_kwh, result.current_year_electricity_kwh) * 100,
                    Float, true, :benchmark),
        format_unit(result.previous_year_electricity_co2, Float, true, :benchmark),
        format_unit(result.current_year_electricity_co2, Float, true, :benchmark),
        format_unit(percent_change(result.previous_year_electricity_co2, result.current_year_electricity_co2) * 100,
                    Float, true, :benchmark),
        format_unit(result.previous_year_electricity_gbp, Float, true, :benchmark),
        format_unit(result.current_year_electricity_gbp, Float, true, :benchmark),
        format_unit(percent_change(result.previous_year_electricity_gbp, result.current_year_electricity_gbp) * 100,
                    Float, true, :benchmark),
        result.solar_type == 'synthetic' ?
          t('common.labels.yes_label') : t('common.labels.no_label')
      ]
  end
end.html_safe
