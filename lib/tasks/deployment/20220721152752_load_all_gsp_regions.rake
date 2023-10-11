require 'csv'
namespace :after_party do
  desc 'Deployment task: load_all_gsp_regions'
  task load_all_gsp_regions: :environment do
    puts "Running deploy task 'load_all_gsp_regions'"

    file_name = File.join(__dir__, 'gsp_centroids_20220314.csv')
    CSV.foreach(file_name, headers: true) do |row|
      gsp_id = row[0]
      gsp_name = row[1]
      centroid_longitude = row[2]
      centroid_latitude = row[3]
      area = SolarPvTuosArea.find_by(gsp_id: gsp_id.to_i)
      if area.present?
        area.update(
          title: "Region #{gsp_id}",
          gsp_name: gsp_name,
          latitude: centroid_latitude,
          longitude: centroid_longitude
        )
      else
        warn "Creating new inactive region for #{gsp_id}"
        SolarPvTuosArea.create!(
          active: false,
          title: "Region #{gsp_id}",
          gsp_id: gsp_id.to_i,
          gsp_name: gsp_name,
          latitude: centroid_latitude.to_f,
          longitude: centroid_longitude.to_f
        )
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
