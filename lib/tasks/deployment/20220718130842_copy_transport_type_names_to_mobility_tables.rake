namespace :after_party do
  desc 'Deployment task: copy_transport_type_names_to_mobility_tables'
  task copy_transport_type_names_to_mobility_tables: :environment do
    puts "Running deploy task 'copy_transport_type_names_to_mobility_tables'"

    TransportType.transaction do
      TransportType.all.each do |transport_type|
        transport_type.update(name: transport_type.read_attribute(:name))
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
