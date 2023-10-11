namespace :after_party do
  desc 'Deployment task: change_park_and_stride_transport_type_category'
  task change_park_and_stride_transport_type_category: :environment do
    TransportType.find_by(name: 'Park and Stride').update(category: :park_and_stride)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
