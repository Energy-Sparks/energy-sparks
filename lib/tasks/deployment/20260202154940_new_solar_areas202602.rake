# rubocop:disable Metrics/BlockLength
namespace :after_party do
  desc 'Deployment task: new_solar_areas202602'
  task new_solar_areas202602: :environment do
    puts "Running deploy task 'new_solar_areas202602'"

    # In the last set of boundaries these were merged together, they've
    # now been broken down into separate areas, so need to add new records
    {
      343 => { name: 'BRLE_1', long: -1.2471275194, lat: 51.4055199728 },
      344 => { name: 'FLEE_1', long: -0.8559940178, lat: 51.1960143496 },
      345 => { name: 'IVER_1', long: -0.5823606537, lat: 51.5460584825 },
      346 => { name: 'IVER_6', long: -0.4588159015, lat: 51.5379483245 },
      347 => { name: 'SAFO_1', long: -2.8034640576, lat: 51.3290977974 },
      348 => { name: 'SEAB1', long: -2.5657590903, lat: 51.3097990608 }
    }.each do |gsp_id, data|
      area = SolarPvTuosArea.find_or_create_by(gsp_id:)
      area.update!(
        active: true,
        title: "Region #{gsp_id}",
        gsp_name: data[:name],
        description: 'New areas from 20251204 NESO boundaries',
        latitude: data[:lat],
        longitude: data[:long],
        back_fill_years: 8
      )
    end

    # These are the old areas, they need to be made inactive so we no
    # longer load data for them
    to_disable = {
      41 => 'BRLE_1|FLEE_1',
      158 => 'IVER_1|IVER_6',
      257 => 'SEAB1|SAFO_1'
    }
    to_disable.each do |gsp_id, gsp_name|
      area = SolarPvTuosArea.find_by_gsp_id(gsp_id)
      if area
        area.update(
          description: "Area split. Was #{gsp_name}",
          gsp_id: nil,
          active: false
        )
      end
    end

    # Reassign areas for around 160 schools, so they should pick up
    # one of the above new areas, or an existing nearby area which
    # may now be closer.
    School.active.where(solar_pv_tuos_area: SolarPvTuosArea.where(gsp_id: to_disable.keys)).find_each do |school|
      Solar::SolarAreaLookupService.new(school).assign(scope: SolarPvTuosArea.active.assignable, trigger_load: false)
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
# rubocop:enable Metrics/BlockLength
