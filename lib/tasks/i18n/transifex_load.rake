namespace :i18n do
  desc 'run transifex loader to synchronise content from the database'
  task :transifex_load do
    puts "#{DateTime.now.utc} transifex_load start"
    begin
      Transifex::Loader.new.perform
    rescue => e
      puts "Exception: running transifex_load: #{e.class} #{e.message}"
      puts e.backtrace.join("\n")
      Rails.logger.error "Exception: running transifex_load: #{e.class} #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e, job: :transifex_load)
    end
    puts "#{DateTime.now.utc} transifex_load end"
  end
end
