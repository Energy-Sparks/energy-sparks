namespace :after_party do
  desc 'Deployment task: add_transport_type_categories'
  task add_transport_type_categories: :environment do
    puts "Running deploy task 'add_transport_type_categories'"

    TransportSurvey::TransportType.where(name: ["Car", "Car (Diesel)", "Car (Petrol)", "Car (Hybrid)", "Electric Car", "Taxi"]).update_all(category: :car)
    TransportSurvey::TransportType.where(name: ["Motorbike"]).update_all(category: nil)
    TransportSurvey::TransportType.where(name: ["Walking", "Bike", "Park and Stride"]).update_all(category: :active_travel)
    TransportSurvey::TransportType.where(name: ["Bus (London)", "Bus", "Train", "Tube", "School bus"]).update_all(category: :public_transport)

    # Update electric car symbol while we're here
    TransportSurvey::TransportType.where(name: "Electric Car").update_all(image: "🔌🚘")

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
