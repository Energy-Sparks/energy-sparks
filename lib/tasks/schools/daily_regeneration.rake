namespace :school do
  desc "Schools daily regeneration"
  task daily_regeneration: :environment do
    puts "#{DateTime.now.utc} Run daily regeneration for all process data schools start"
    BenchmarkResultGenerationRun.create!
    School.process_data.order(:name).each do |school|
      puts "Run daily regeneration job for #{school.name}"
      begin
        DailyRegenerationJob.perform_later(school: school)
      rescue => e
        puts "Exception: running validation for #{school.name}: #{e.class} #{e.message}"
        puts e.backtrace.join("\n")
        Rails.logger.error "Exception: running validation for #{school.name}: #{e.class} #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        Rollbar.error(e, job: :daily_regeneration, school_id: school.id, school: school.name)
      end
    end
    puts "#{DateTime.now.utc} Run daily regeneration for all process data schools end"
  end
end
