# frozen_string_literal: true

CSV.generate do |csv|
  csv << csv_colgroups(@colgroups)
  csv << @headers
  @results.each do |result|
    data = [result.school.name]
    data << result.fuel_type_names
    data << result.activation_date.iso8601
    %i[kwh co2 £].each do |unit|
      data << format_unit(result.total_previous_period(unit: unit), Float, true, :benchmark)
      data << format_unit(result.total_current_period(unit: unit), Float, true, :benchmark)
      data << format_unit(result.total_percentage_change(unit: unit) * 100, Float, true, :benchmark)
    end
    csv << data
  end
end.html_safe
