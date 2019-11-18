namespace :after_party do
  desc 'Deployment task: reset_long_furlong_low_carbon_hub'
  task reset_long_furlong_low_carbon_hub: :environment do
    puts "Running deploy task 'reset_long_furlong_low_carbon_hub'"

    ActiveRecord::Base.transaction do
      api = LowCarbonHubMeterReadings.new
      school = School.find('long-furlong-primary-school')
      school.low_carbon_hub_installations.each do |installation|
        first_reading_date = api.first_meter_reading_date(installation.rbee_meter_id)
        Amr::LowCarbonHubDownloadAndUpsert.new(
          low_carbon_hub_installation: installation,
          start_date: first_reading_date,
          end_date: Date.yesterday,
          low_carbon_hub_api: api
        ).perform
      end
      Amr::ValidateAndPersistReadingsService.new(school).perform
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
