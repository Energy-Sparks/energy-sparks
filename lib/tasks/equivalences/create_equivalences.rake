namespace :equivalences do
  desc 'Run equivalences job'
  task create: [:environment] do
    puts "#{DateTime.now.utc} Generate equivalences start"

    schools = School.process_data.with_config
    schools.each do |school|
      begin
        puts "Running all equivalences for #{school.name}"
        Equivalences::GenerateEquivalences.new(school: school).perform
      rescue => e
        Rails.logger.error("#{e.message} for #{school.name}")
        Rollbar.error(e, job: :create_equivalences, school_id: school.id, school: school.name)
      end

    end
    puts "#{DateTime.now.utc} Generate equivalences end"
  end
end
