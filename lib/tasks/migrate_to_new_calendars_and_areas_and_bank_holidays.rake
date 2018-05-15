namespace :loader do
  desc 'Load energy usage data for all schools'
  task calendar_migration: [:environment] do
    # Create areas
    puts "Create areas"
    england = Group.where(title: 'England and Wales').first_or_create
    banes = Group.where(title: 'Bristol and North East Somerset (BANES)', parent_group: england).first_or_create

    # Clear calendars
    School.update_all(calendar_id: nil)
    Term.delete_all
    CalendarEvent.delete_all
    CalendarEventType.delete_all
    Calendar.delete_all

    # Create calendar event types
    puts "Create calendar event types"
    CalendarEventType.where(title: 'Term 1', description: 'Autumn Half Term 1', occupied: true, term_time: true).first_or_create
    CalendarEventType.where(title: 'Term 2', description: 'Autumn Half Term 2', occupied: true, term_time: true).first_or_create
    CalendarEventType.where(title: 'Term 3', description: 'Spring Half Term 1', occupied: true, term_time: true).first_or_create
    CalendarEventType.where(title: 'Term 4', description: 'Spring Half Term 2', occupied: true, term_time: true).first_or_create
    CalendarEventType.where(title: 'Term 5', description: 'Summer Half Term 1', occupied: true, term_time: true).first_or_create
    CalendarEventType.where(title: 'Term 6', description: 'Autumn Half Term 2', occupied: true, term_time: true).first_or_create
    # Load Bank Holidays

    # Load BANES calendar
    Loader::Calendars.load!("etc/banes-default-calendar.csv")

    # Update schools to have BANES calendar as default
    School.all.update(calendar: Calendar.first, group: banes)
  end
end
