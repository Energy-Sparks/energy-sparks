namespace :alerts do
  desc 'Run alerts job'
  task create: [:environment] do
    puts "#{DateTime.now.utc} Generate alerts start"
    schools = School.process_data.with_config
    schools.each do |school|
      puts "Running all alerts for #{school.name}"
      Alerts::GenerateAndSaveAlertsAndBenchmarks.new(school: school).perform
    end
    puts "#{DateTime.now.utc} Generate alerts end"
  end
end
