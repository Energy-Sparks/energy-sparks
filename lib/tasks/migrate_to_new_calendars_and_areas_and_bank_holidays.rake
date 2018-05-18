namespace :loader do
  desc 'Load energy usage data for all schools'
  task calendar_migration: [:environment] do
    # Create areas
    puts "Create areas"
    england = Area.where(title: 'England and Wales').first_or_create
    banes = Area.where(title: 'Bristol and North East Somerset (BANES)', parent_area: england).first_or_create
    sheff = Area.where(title: 'Sheffield', parent_area: england).first_or_create

    # Clear calendars
    School.update_all(calendar_id: nil)
    Term.delete_all
    CalendarEvent.delete_all
    CalendarEventType.delete_all
    Calendar.delete_all
    AcademicYear.delete_all

    # Create calendar event types
    puts "Create calendar event types"
    term_colour = 'rgb(245, 187, 0)'
    CalendarEventType.where(title: 'Term 1', description: 'Autumn Half Term 1', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 2', description: 'Autumn Half Term 2', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 3', description: 'Spring Half Term 1', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 4', description: 'Spring Half Term 2', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 5', description: 'Summer Half Term 1', school_occupied: true, term_time: true, colour: term_colour).first_or_create
    CalendarEventType.where(title: 'Term 6', description: 'Autumn Half Term 2', school_occupied: true, term_time: true, colour: term_colour).first_or_create

    (1990..2030).each { |year| AcademicYear.where(start_date: Date.parse("01-09-#{year}"), end_date: "31-08-#{year + 1}").first_or_create }

    # Load Bank Holidays
    Loader::BankHolidays.load!("etc/bank_holidays/england-and-wales.json")

    # Load BANES calendar
    Loader::Calendars.load!("etc/banes-default-calendar.csv", banes)
    Loader::Calendars.load!("etc/sheffield-default-calendar.csv", sheff)

    # Update schools to have BANES calendar as default
    School.all.update(calendar: Calendar.first, calendar_area: banes)

    Calendar.all.each { |calendar| HolidayFactory.new(calendar).build }
  end
end
