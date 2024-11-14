# rubocop:disable Lint/ParenthesesAsGroupedExpression
json.calendar_events (@first_reading.reading_date.to_date..Time.zone.today).each do |the_date|
  json.startDate  the_date
  json.endDate    the_date
  if @reading_summary.key?(the_date)
    json.name @reading_summary[the_date].round(3)
    if @reading_summary[the_date] > 20.0
      json.color Colours.hex(:red_medium)
    elsif @reading_summary[the_date] > AnalyseHeatingAndHotWater::HeatingModelTemperatureSpace::BALANCE_POINT_TEMPERATURE
      json.color Colours.hex(:yellow_medium)
    elsif @reading_summary[the_date] > 5.0
      json.color Colours.hex(:teal_medium)
    else
      json.color Colours.hex(:blue_medium)
    end
  else
    json.name 'Missing'
    json.color Colours.hex(:red_dark)
  end
end
# rubocop:enable Lint/ParenthesesAsGroupedExpression
