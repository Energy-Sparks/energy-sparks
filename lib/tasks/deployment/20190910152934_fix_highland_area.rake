namespace :after_party do
  desc 'Deployment task: fix_highland_area'
  task fix_highland_area: :environment do
    puts "Running deploy task 'fix_highland_area'"

    # Put your task implementation HERE.

    dsa = DarkSkyArea.find_by(title: "Highlands")

   # <DarkSkyArea id: 17, type: "DarkSkyArea", title: "Highlands", description: nil, latitude: 0.57565289e2, longitude: -0.4432566e1>

    ca = CalendarArea.find_by(title: "Highland")

   # <CalendarArea id: 25, title: "Highland", parent_id: 17>

    sg = SchoolGroup.find_by(name: "Highlands")

    ActiveRecord::Base.transaction do
      sg.update(default_dark_sky_area_id: dsa.id, default_calendar_area_id: ca)

      sg.schools.each do |school|
        school.update(dark_sky_area_id: sg.default_dark_sky_area_id)
      end
    end


    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end