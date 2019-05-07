namespace :after_party do
  desc 'Deployment task: migrate_dark_sky_areas'
  task migrate_dark_sky_areas: :environment do
    puts "Running deploy task 'migrate_dark_sky_areas'"

    # Put your task implementation HERE.
    School.all.each do |school|
      weather_underground_area_title = school.weather_underground_area.title
      dark_sky_area = DarkSkyArea.find_by(title: weather_underground_area_title)

      school.update(dark_sky_area: dark_sky_area)
    end
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20190501135438'
  end
end
