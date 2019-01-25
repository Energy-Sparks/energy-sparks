namespace :alerts do
  desc 'Run alerts job'
  task create_termly: [:environment] do
    puts Time.zone.now
    schools = School.active
    schools.each do |school|
      puts "Running alerts for #{school.name}"

      # Decide when to run this for each school
      # Half termly
      Alerts::GenerateAndSaveAlerts.new(school).termly_alerts
    end
    puts Time.zone.now
  end
end
