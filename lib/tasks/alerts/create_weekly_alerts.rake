namespace :alerts do
  desc 'Run alerts job'
  task create_weekly: [:environment] do
    puts Time.zone.now
    schools = School.active
    schools.each do |school|
      puts "Running alerts for #{school.name}"
      Alerts::BuildAndUpsert.new(school).generate_weekly_alerts
    end
    puts Time.zone.now
  end
end
