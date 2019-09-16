namespace :after_party do
  desc 'Deployment task: set_up_long_furlong'
  task set_up_long_furlong: :environment do
    puts "Running deploy task 'set_up_long_furlong'"

    # Put your task implementation HERE.
    long_furlong = School.find_by(name: 'Long Furlong Primary School')

		# Replace this with new factory once ready
    installation = Amr::LowCarbonHubInstallationFactory.new(school: long_furlong, rbee_meter_id: 216057958).perform

    pp installation
    pp installation.meters

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
