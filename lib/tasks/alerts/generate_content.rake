namespace :alerts do
  desc 'Run alert content job'
  task generate_content: [:environment] do
    puts "#{DateTime.now.utc} Generate content start"
    schools = School.process_data.with_config

    schools.each do |school|
      puts "Running alert content generation for #{school.name}"
      Alerts::GenerateContent.new(school).perform
    end

    puts "#{DateTime.now.utc} Generate content end"
  end
end
