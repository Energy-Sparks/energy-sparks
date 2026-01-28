namespace :after_party do
  desc 'Deployment task: import_contracts_and_licences'
  task import_contracts_and_licences: :environment do
    puts "Running deploy task 'import_contracts_and_licences'"

    service = Commercial::ImportFromFunderAllocationService.new

    file_name = File.join(__dir__, 'contracts-and-licensing-import-test.csv')

    CSV.foreach(file_name, headers: true) do |row|
      school_name = row['School name']
      funder_name = row['Funder']&.rstrip
      # FIXME other columns
      service.import(funder_name, school_name)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
