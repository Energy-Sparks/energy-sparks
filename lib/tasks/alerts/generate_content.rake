namespace :alerts do
  desc 'Run alert content job'
  task generate_content: [:environment] do
    puts Time.zone.now
    schools = School.process_data.with_config

    schools.each do |school|
      puts "Running alert content generation for #{school.name}"
      Alerts::GenerateContent.new(school).perform
    end

    puts Time.zone.now
  end
end
