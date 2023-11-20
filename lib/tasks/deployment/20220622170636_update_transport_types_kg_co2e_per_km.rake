namespace :after_party do
  desc 'Deployment task: update_transport_types_kg_co2e_per_km'
  task update_transport_types_kg_co2e_per_km: :environment do
    puts "Running deploy task 'update_transport_types_kg_co2e_per_km'"

    # Update kg_co2e_per_km figures from:
    # https://www.gov.uk/government/publications/greenhouse-gas-reporting-conversion-factors-2021
    # See: "full set for advanced users" document in the "business travel - land" tab

    # current_kg_co2e_per_km: the value currently in the database (not used, just for reference)
    # kg_co2e_per_km: new value to be used
    # current_note: current note in the db (again, not used, just for reference)
    # note: new note value
    # can_share: new can_share value

    # NB Taxi has been updated to use the gov.uk value for Regular taxi - per passenger value.
    # It previously used the value for Car.
    # This also means can_share needs to be set to false as we're using the per-passenger value, rather for the whole vehicle one.

    # The notes for Train, Tube and Taxi have been updated - Train and Tube previously had no note, so have added them to show where the values have come from
    # The note for taxi has changed too, to reflect that it is now using the value for Regular taxi and not Car (as it was previously)

    data = [
      { current_kg_co2e_per_km: 0.17137,  kg_co2e_per_km: 0.17148,  name: 'Car',              current_note: 'Average car, unknown size or fuel type' },
      { current_kg_co2e_per_km: 0.16844,  kg_co2e_per_km: 0.16843,  name: 'Car (Diesel)',     current_note: 'Average diesel car, unknown size' },
      { current_kg_co2e_per_km: 0.1743,   kg_co2e_per_km: 0.17431,  name: 'Car (Petrol)',     current_note: 'Average petrol car, unknown size' },
      { current_kg_co2e_per_km: 0.11558,  kg_co2e_per_km: 0.11952,  name: 'Car (Hybrid)',     current_note: 'Average hybrid car, unknown size' },
      { current_kg_co2e_per_km: 0.11337,  kg_co2e_per_km: 0.11355,  name: 'Motorbike',        current_note: 'Average motorbike, unknown size' },
      { current_kg_co2e_per_km: 0.05274,  kg_co2e_per_km: 0.05477,  name: 'Electric Car',     current_note: 'Average electric car, unknown size' },
      { current_kg_co2e_per_km: 0.0,      kg_co2e_per_km: 0.0,      name: 'Walking',          current_note: '' },
      { current_kg_co2e_per_km: 0.07856,  kg_co2e_per_km: 0.07718,  name: 'Bus (London)',     current_note: 'Average London bus' },
      { current_kg_co2e_per_km: 0.1195,   kg_co2e_per_km: 0.11774,  name: 'Bus',              current_note: 'Average Non-London bus' },
      { current_kg_co2e_per_km: 0.03694,  kg_co2e_per_km: 0.03549,  name: 'Train',            current_note: '', note: 'National Rail' }, # note updated
      { current_kg_co2e_per_km: 0.0275,   kg_co2e_per_km: 0.02781,  name: 'Tube',             current_note: '', note: 'London Underground' }, # note updated
      { current_kg_co2e_per_km: 0.1195,   kg_co2e_per_km: 0.11774,  name: 'School bus',       current_note: 'Average Non-London bus' },
      { current_kg_co2e_per_km: 0.17137,  kg_co2e_per_km: 0.14876,  name: 'Taxi',             current_note: 'Average car, unknown size or fuel type', note: 'Regular taxi', can_share: false }, # note & can_share updated
      { current_kg_co2e_per_km: 0.17137,  kg_co2e_per_km: 0.17148,  name: 'Park and Stride',  current_note: 'Park and Stride, car emmisions but assumed 15 mins walked' },
      { current_kg_co2e_per_km: 0.0,      kg_co2e_per_km: 0.0,      name: 'Bike',             current_note: '' }
    ]

    data.each do |row|
      type = TransportSurvey::TransportType.find_by(name: row[:name])
      type.update(row.slice(:kg_co2e_per_km, :note, :can_share))
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
