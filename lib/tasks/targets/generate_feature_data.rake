namespace :targets do
  desc 'Generate target fuel types and progress report'
  task generate_feature_data: [:environment] do
    puts "#{Time.zone.now} targets:generate_feature_data start"
    School.process_data.each do |school|
      begin
        puts "Running for #{school.name}"
        aggregate_school = AggregateSchoolService.new(school).aggregate_school
        #store whether enough data
        fuel_types = Targets::GenerateFuelTypes.new(school, aggregate_school).perform
        configuration = Schools::Configuration.where(school: school).first_or_create
        configuration.update!(school_target_fuel_types: fuel_types)
        school.reload
        Targets::GenerateProgressService.new(school, aggregate_school).generate!
      rescue => e
        puts "Generation of feature data for #{school.name} because #{e.message}"
        puts e.backtrace
      end
    end
    puts "#{Time.zone.now} targets:generate_feature_data end"
  end
end
