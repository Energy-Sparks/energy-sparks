json.calendar_events (@first_reading.read_at.to_date..Date.today).each do |the_date|
  json.startDate  the_date
  json.endDate    the_date
  if @reading_summary.key?(the_date)
    json.name @reading_summary[the_date]
    if @reading_summary[the_date] == 48
      json.color 'rgb(92,184,92)'
    else
      json.color 'rgb(255,172,33)'
    end
  else
    json.name 'Missing'
    json.color 'rgb(255,69,0)'
  end
end
