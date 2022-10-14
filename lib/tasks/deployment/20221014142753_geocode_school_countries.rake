namespace :after_party do
  desc 'Deployment task: geocode_school_countries'
  task geocode_school_countries: :environment do
    puts "Running deploy task 'geocode_school_countries'"

    # Put your task implementation HERE.
    School.all.each do |school|
      school.geocode
      if school.country_changed?
        puts "#{school.name} : country was #{school.country_was}, now #{school.country}"
        school.save!
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
