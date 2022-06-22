namespace :after_party do
  desc 'Deployment task: upate_transport_types_kg_co2e_per_km'
  task upate_transport_types_kg_co2e_per_km: :environment do
    puts "Running deploy task 'upate_transport_types_kg_co2e_per_km'"

    # Update kg_co2e_per_km figures from:
    # https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2021
    # See: "full set for advanced users" document in the "business travel - land" tab

    # kg_co2e_per_km: new value to be used
    # old_kg_co2e_per_km: is the value currently in the database, so it is easy to spot any large discrepancies
    # note: is also in here for reference

    data = [
      { old_kg_co2e_per_km: 0.17137,  kg_co2e_per_km: 0.17148,  name: 'Car',              note: 'Average car, unknown size or fuel type' },
      { old_kg_co2e_per_km: 0.16844,  kg_co2e_per_km: 0.16843,  name: 'Car (Diesel)',     note: 'Average diesel car, unknown size' },
      { old_kg_co2e_per_km: 0.1743,   kg_co2e_per_km: 0.17431,  name: 'Car (Petrol)',     note: 'Average petrol car, unknown size' },
      { old_kg_co2e_per_km: 0.11558,  kg_co2e_per_km: 0.11952,  name: 'Car (Hybrid)',     note: 'Average hybrid car, unknown size' },
      { old_kg_co2e_per_km: 0.11337,  kg_co2e_per_km: 0.11355,  name: 'Motorbike',        note: 'Average motorbike, unknown size' },
      { old_kg_co2e_per_km: 0.05274,  kg_co2e_per_km: 0.05477,  name: 'Electric Car',     note: 'Average electric car, unknown size' },
      #{ old_kg_co2e_per_km: 0.0,      kg_co2e_per_km: 0.0,        name: 'Walking',          note: '' },
      { old_kg_co2e_per_km: 0.07856,  kg_co2e_per_km: 0.07718,  name: 'Bus (London)',     note: 'Average London bus' },
      { old_kg_co2e_per_km: 0.1195,   kg_co2e_per_km: 0.11774,  name: 'Bus',              note: 'Average Non-London bus' },
      { old_kg_co2e_per_km: 0.03694,  kg_co2e_per_km: 0.03549,  name: 'Train',            note: '' },
      { old_kg_co2e_per_km: 0.0275,   kg_co2e_per_km: 0.02781,  name: 'Tube',             note: '' },
      { old_kg_co2e_per_km: 0.1195,   kg_co2e_per_km: 0.11774,  name: 'School bus',       note: 'Average Non-London bus' },

      # NB TAXI - in the file, a "Regular taxi" has a value of 0.20826, however, it looks like this previously used the same value as Car.
      # So should we carry on using the same value as Car or use the average taxi value?
      { old_kg_co2e_per_km: 0.17137,  kg_co2e_per_km: 0.17148,  name: 'Taxi',             note: 'Average car, unknown size or fuel type' },

      { old_kg_co2e_per_km: 0.17137,  kg_co2e_per_km: 0.17148,  name: 'Park and Stride',  note: 'Park and Stride, car emmisions but assumed 15 mins walked' },
      #{ old_kg_co2e_per_km: 0.0,      kg_co2e_per_km: 0.0,      name: 'Bike',             note: '' }
    ]

    data.each do |row|
      type = TransportType.find_by(name: row[:name])
      puts "Updating #{row[:name]} from #{type.kg_co2e_per_km} to #{row[:kg_co2e_per_km]}"
      # type.update(kg_co2e_per_km: row[:kg_co2e_per_km])
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end