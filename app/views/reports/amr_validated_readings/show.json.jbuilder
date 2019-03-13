# rubocop:disable Lint/ParenthesesAsGroupedExpression
json.calendar_events (@first_validated_reading_date..Time.zone.today).each do |the_date|
  json.startDate  the_date
  json.endDate    the_date
  if @reading_summary.key?(the_date)
    json.name @reading_summary[the_date][:description]
    json.color @reading_summary[the_date][:colour]
  else
    json.name 'Missing'
    json.color 'rgb(255,69,0)'
  end
end
# rubocop:enable Lint/ParenthesesAsGroupedExpression
