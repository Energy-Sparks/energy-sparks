# frozen_string_literal: true

namespace :after_party do # rubocop:disable Metrics/BlockLength
  desc 'Deployment task: solar_areas2026'
  task solar_areas2026: :environment do # rubocop:disable Metrics/BlockLength
    puts "Running deploy task 'solar_areas2026'"

    # These are no longer updating, force gsp_id to nil so they are no longer assignable
    # To be cleaned up later
    SolarPvTuosArea.where(gsp_id: [4, 56, 122]).update_all(gsp_id: nil, active: false) # rubocop:disable Rails/SkipsModelValidations

    # Load and populate all the latest GSP areas with their centroids
    #
    # If id and location haven't changed then avoid creating new records
    file_name = File.join(__dir__, 'gsp-areas-2026.csv')
    CSV.foreach(file_name, headers: true) do |row|
      area = SolarPvTuosArea.find_or_initialize_by(
        gsp_id: row['gsp_id'],
        latitude: row['lat'],
        longitude: row['long']
      )
      area.assign_attributes(
        title: "Region #{row['gsp_id']}",
        description: 'Derived from NESPO GSP Regions 20260209',
        gsp_name: row['gsp_name'],
        back_fill_years: 8
      )
      area.save!

      # If there was an existing area with same gsp_id then remove it
      # Means the boundaries have changed
      SolarPvTuosArea.where(gsp_id: row['gsp_id']).where.not(id: area.id).update(gsp_id: nil)
    end

    # Reassign schools to areas
    School.active.find_each do |school|
      Solar::SolarAreaLookupService.new(school).assign(scope: SolarPvTuosArea.active.assignable, trigger_load: false)
    end

    # Disable any areas not currently linked to schools
    SolarPvTuosArea.where.not(id: School.active.select(:solar_pv_tuos_area_id)).update_all(active: false) # rubocop:disable Rails/SkipsModelValidations

    # Remove no longer updating areas and ensure any older unused areas are removed.
    SolarPvTuosArea.where(gsp_id: nil).destroy_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
