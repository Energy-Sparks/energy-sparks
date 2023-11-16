namespace :after_party do
  desc 'Deployment task: Populate transport types'
  task populate_transport_types: :environment do
    puts "Running deploy task 'populate_transport_types'"

    rows = [
      { image: '🚗',   can_share: true,  kg_co2e_per_km: 0.17137,  speed_km_per_hour: 32, name: 'Car', note: 'Average car, unknown size or fuel type' },
      { image: '🚘',   can_share: true,  kg_co2e_per_km: 0.16844,  speed_km_per_hour: 32, name: 'Car (Diesel)', note: 'Average diesel car, unknown size' },
      { image: '🚘',   can_share: true,  kg_co2e_per_km: 0.1743,   speed_km_per_hour: 32, name: 'Car (Petrol)', note: 'Average petrol car, unknown size' },
      { image: '🚘',   can_share: true,  kg_co2e_per_km: 0.11558,  speed_km_per_hour: 32, name: 'Car (Hybrid)', note: 'Average hybrid car, unknown size' },
      { image: '🏍️',   can_share: false, kg_co2e_per_km: 0.11337,  speed_km_per_hour: 32, name: 'Motorbike', note: 'Average motorbike, unknown size' },
      { image: '🔌',   can_share: true,  kg_co2e_per_km: 0.05274,  speed_km_per_hour: 32, name: 'Electric Car', note: 'Average electric car, unknown size' },
      { image: '🥾',   can_share: false, kg_co2e_per_km: 0,        speed_km_per_hour: 5,  name: 'Walking', note: '' },
      { image: '🚌',   can_share: false, kg_co2e_per_km: 0.07856,  speed_km_per_hour: 25, name: 'Bus (London)', note: 'Average London bus' },
      { image: '🚌',   can_share: false, kg_co2e_per_km: 0.1195,   speed_km_per_hour: 25, name: 'Bus', note: 'Average Non-London bus' },
      { image: '🚆',   can_share: false, kg_co2e_per_km: 0.03694,  speed_km_per_hour: 25, name: 'Train', note: '' },
      { image: '🚇',   can_share: false, kg_co2e_per_km: 0.0275,   speed_km_per_hour: 25, name: 'Tube', note: '' },
      { image: '🚌',   can_share: false, kg_co2e_per_km: 0.1195,   speed_km_per_hour: 25, name: 'School bus', note: 'Average Non-London bus' },
      { image: '🚗',   can_share: true,  kg_co2e_per_km: 0.17137,  speed_km_per_hour: 32, name: 'Taxi', note: 'Average car, unknown size or fuel type' },
      { image: '🚶🚘', can_share: true,  kg_co2e_per_km: 0.17137,  speed_km_per_hour: 32, name: 'Park and Stride', note: 'Park and Stride, car emmisions but assumed 15 mins walked' },
      { image: '🚲',   can_share: false, kg_co2e_per_km: 0,        speed_km_per_hour: 5,  name: 'Bike', note: '' }
    ]

    rows.each_with_index do |_val, i|
      rows[i].merge!({ created_at: DateTime.now, updated_at: DateTime.now })
    end

    TransportSurvey::TransportType.upsert_all(rows, unique_by: :name)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
