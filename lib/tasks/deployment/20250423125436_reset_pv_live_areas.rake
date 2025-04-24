namespace :after_party do
  desc 'Deployment task: reset_pv_live_areas'
  task reset_pv_live_areas: :environment do
    puts "Running deploy task 'reset_pv_live_areas'"

    # Remove any existing areas without schools
    SolarPvTuosArea.all.each do |area|
      area.destroy! unless area.schools.any?
    end

    # Disable all remaining areas. remove gsp_id
    SolarPvTuosArea.all.update!(active: false, gsp_id: nil)

    # Load all GSP regions and their centroids, as active
    file = File.join(__dir__, "gsp-regions-2025.csv")
    CSV.foreach( file, headers: true ) do |row|
      gsp_name = row[0]
      centroid_longitude = row[1]
      centroid_latitude = row[2]
      SolarPvTuosArea.create!(
        title: gsp_name,
        gsp_name: gsp_name,
        description: 'Derived from NESPO GSP Regions 20250109',
        latitude: centroid_latitude.to_f,
        longitude: centroid_longitude.to_f,
        back_fill_years: 8
      ) unless gsp_name.include?('Off_')
    end

    # Load GSP ids
    file = File.join(__dir__, "gsp-list-2025.csv")
    CSV.foreach( file, headers: true ) do |row|
      gsp_id = row[0]
      gsp_name = row[1]
      next if gsp_name == 'NATIONAL'
      area = SolarPvTuosArea.where(active: true, gsp_name: gsp_name).first
      if area.present?
        area.update!(title: "Region #{gsp_id}", gsp_id: gsp_id)
      else
        $stderr.puts "Unable to find area #{gsp_name}"
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
