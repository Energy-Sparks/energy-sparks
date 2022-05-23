namespace :after_party do
  desc 'Deployment task: set_country_and_funding_status_on_schools'
  task set_country_and_funding_status_on_schools: :environment do
    puts "Running deploy task 'set_country_and_funding_status_on_schools'"

    School.transaction do
      School.all.each do |school|
        school.update(country: Schools::CountryLookup.new(school).country)
        school.update(funding_status: Schools::FundingStatusLookup.new(school).funding_status)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
