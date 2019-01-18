namespace :alerts do
  desc 'Run alerts job'
  task daily_create: [:environment] do
    puts Time.zone.now
    schools = School.active
    schools.each do |school|
      puts "Running alerts for #{school.name}"
      Alerts::BuildAndUpsert.new(school).perform
    end
    puts Time.zone.now
  end
end
