# frozen_string_literal: true

CSV.generate do |csv|
  csv << csv_colgroups(@colgroups)
  csv << @headers
  @results.each do |result|
    csv << [
      result.school.name,
      format_unit(result.previous_out_of_hours_kwh, Float, true, :benchmark),
      format_unit(result.out_of_hours_kwh, Float, true, :benchmark),
      format_csv_percent_change(result.previous_out_of_hours_kwh, result.out_of_hours_kwh),
      format_unit(result.previous_out_of_hours_co2, Float, true, :benchmark),
      format_unit(result.out_of_hours_co2, Float, true, :benchmark),
      format_csv_percent_change(result.previous_out_of_hours_co2, result.out_of_hours_co2),
      format_unit(result.previous_out_of_hours_gbpcurrent, Float, true, :benchmark),
      format_unit(result.out_of_hours_gbpcurrent, Float, true, :benchmark),
      format_csv_percent_change(result.previous_out_of_hours_gbpcurrent, result.out_of_hours_gbpcurrent)
    ]
  end
end.html_safe
