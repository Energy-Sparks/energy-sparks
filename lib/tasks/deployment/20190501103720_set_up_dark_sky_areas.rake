namespace :after_party do
  desc 'Deployment task: set_up_dark_sky_areas'
  task set_up_dark_sky_areas: :environment do
    puts "Running deploy task 'set_up_dark_sky_areas'"

    # Put your task implementation HERE.
    Areas::DarkSkyArea.create(title: 'Bath',       latitude: 51.39,    longitude: -2.37)
    Areas::DarkSkyArea.create(title: 'Sheffield',  latitude: 53.3811,  longitude: -1.4701)
    Areas::DarkSkyArea.create(title: 'Frome',      latitude: 51.2308,  longitude: -2.3201)
    Areas::DarkSkyArea.create(title: 'Abingdon',   latitude: 51.67,    longitude: -1.285)
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20190501103720'
  end
end
