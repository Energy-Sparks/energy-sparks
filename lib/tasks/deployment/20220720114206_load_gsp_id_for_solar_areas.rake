require 'csv'

namespace :after_party do
  desc 'Deployment task: Load CSV file containing gsp areas'
  task load_gsp_id_for_solar_areas: :environment do
    puts "Running deploy task 'load_gsp_id_for_solar_areas'"

    file_name = File.join(__dir__, 'tuos_areas_to_gsp_id.csv')
    CSV.foreach(file_name, headers: true) do |row|
      name = row[0]
      gsps = row[3]
      area = SolarPvTuosArea.find_by(title: name)
      if area.present?
        area.update(gsp_name: gsps)
      else
        puts "Unable to match #{name}"
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
