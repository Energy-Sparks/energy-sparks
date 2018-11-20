# rubocop:disable Lint/ParenthesesAsGroupedExpression
require 'dashboard'

json.calendar_events (Date.parse(@first_reading)..Time.zone.today).each do |the_date|
  json.startDate  the_date
  json.endDate    the_date
  if @reading_summary.key?(the_date)
    json.name "#{@reading_summary[the_date]} #{OneDayAMRReading::AMR_TYPES[@reading_summary[the_date]][:name]}"
    json.color @colour_hash[@reading_summary[the_date]].to_s
  else
    json.name 'Missing'
    json.color 'rgb(255,69,0)'
  end
end
# rubocop:enable Lint/ParenthesesAsGroupedExpression
