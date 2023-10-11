namespace :after_party do
  desc 'Deployment task: add_van_and_electric_bike_transport_types'
  task add_van_and_electric_bike_transport_types: :environment do
    puts "Running deploy task 'add_van_and_electric_bike_transport_types'"

    # See the following doc for information on adding and updating transport types:
    # https://docs.google.com/document/d/1uEmInQwth9xjLm3SLk8FWh8i0PqKYERMStE5Amtri2k/edit?usp=sharing

    # Create or update two new transport types
    TransportType.upsert({ name: 'Van',           image: '🚐', speed_km_per_hour: 32.0, kg_co2e_per_km: 0.24017, can_share: true, park_and_stride: false, category: nil, note: 'Average van, unknown size or fuel type', created_at: Time.zone.now, updated_at: Time.zone.now }, unique_by: :name)
    TransportType.upsert({ name: 'Electric Bike', image: '🔌🚲', speed_km_per_hour: 19.3, kg_co2e_per_km: 0.00133, can_share: false, park_and_stride: false, category: 'walking_and_cycling', note: '400Wh battery, 60km per charge, highest assistance level', created_at: Time.zone.now, updated_at: Time.zone.now }, unique_by: :name)

    # These notes needs updating too
    TransportType.find_by(name: 'Park and Stride').update(note: 'Park and Stride, car emmisions but assumed 10 mins walked')

    # Now put in the right order
    order = ['Walking', 'Bike', 'Electric Bike',
             'Park and Stride', 'Car', 'Car (Petrol)', 'Car (Diesel)', 'Car (Hybrid)', 'Electric Car', 'Van', 'Taxi',
             'School bus', 'Bus', 'Bus (London)', 'Train', 'Tube',
             'Motorbike']

    order.each_with_index do |name, position|
      TransportType.find_by(name: name).update(position: position)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
