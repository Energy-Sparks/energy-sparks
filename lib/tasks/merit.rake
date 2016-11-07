namespace :merit do
  # Compares total energy usage between last week and the week before, ignoring energy type.
  # Not all schools will use both gas and electric. Comparing total usage avoids penalising with fewer points
  # schools who only use one type.
  desc 'Award badges/points for fall in weekly energy usage.'
  task reduced_weekly_energy_usage: [:environment] do
    break unless Date.today.saturday?
    ::School.find_each do |school|
      last_saturday = Time.current.last_week(:saturday) # week runs Saturday to Friday
      last_week = school.meter_readings.where(read_at: week.all_week(:saturday)).average(:value)
      week_before = school.meter_readings.where(read_at: last_saturday.weeks_ago(1).all_week(:saturday)).average(:value)
      if week_before > last_week
        school.add_badge(6)
        school.add_points(10)
      end
    end
  end
end
