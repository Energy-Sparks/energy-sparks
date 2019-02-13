namespace :alerts do
  desc 'Run alerts job'
  task create_termly: [:environment] do
    puts Time.zone.now
    schools = School.active
    schools.each do |school|
      puts "Running alerts for #{school.name}"

      # Decide when to run this for each school
      if school.holiday_approaching?
        # Half termly
        Alerts::GenerateAndSaveAlerts.new(school).termly_alerts
      end
    end
    puts Time.zone.now
  end

  task create_termly_regardless: [:environment] do
    puts Time.zone.now
    schools = School.active
    schools.each do |school|
      puts "Running alerts for #{school.name} - regardless of date"

      # Decide when to run this for each school
      Alerts::GenerateAndSaveAlerts.new(school).termly_alerts
    end
    puts Time.zone.now
  end
end
