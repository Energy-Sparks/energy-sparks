namespace :after_party do
  desc 'Deployment task: update_transport_type_position'
  task update_transport_type_position: :environment do
    puts "Running deploy task 'update_transport_type_position'"

    order = ["Walking", "Bike",
             "Park and Stride", "Car", "Car (Petrol)", "Car (Diesel)", "Car (Hybrid)", "Electric Car", "Taxi",
             "School bus", "Bus", "Bus (London)", "Train", "Tube",
             "Motorbike"]

    order.each_with_index do |name, position|
      TransportSurvey::TransportType.find_by(name: name).update(position: position)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
