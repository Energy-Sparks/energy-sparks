namespace :after_party do
  desc 'Deployment task: add_home_nation_calendars'
  task add_home_nation_calendars: :environment do
    puts "Running deploy task 'add_home_nation_calendars'"

    england_and_wales_calendar_area = CalendarArea.find_by(title: 'England and Wales')
    scotland_calendar_area = CalendarArea.find_by(title: 'Scotland')

    # Put your task implementation HERE.
    eawca = Calendar.where(calendar_area: england_and_wales_calendar_area, template: true, title: england_and_wales_calendar_area.title).first_or_create!
    sca = Calendar.where(calendar_area: scotland_calendar_area, template: true, title: scotland_calendar_area.title).first_or_create!

    Calendar.find_by(title: 'Bath and North East Somerset (BANES)').update(based_on_id: eawca.id)
    Calendar.find_by(title: 'Frome').update(based_on_id: eawca.id)
    Calendar.find_by(title: 'Sheffield').update(based_on_id: eawca.id)
    Calendar.find_by(title: 'Oxfordshire').update(based_on_id: eawca.id)

    Calendar.find_by(title: 'Highland').update(based_on_id: sca.id)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end

