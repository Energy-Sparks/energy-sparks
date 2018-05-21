namespace :loader do
  desc 'Load energy usage data for all schools'
  task calendar_migration: [:environment] do
    # Create areas
    puts "Create areas"
    england =   Area.where(title: 'England and Wales').first_or_create
    banes =     Area.where(title: 'Bristol and North East Somerset (BANES)', parent_area: england).first_or_create
    sheff =     Area.where(title: 'Sheffield', parent_area: england).first_or_create

    puts "Reset database"
    # Clear calendars
    School.update_all(calendar_id: nil)
    Term.delete_all
    CalendarEvent.delete_all
    CalendarEventType.delete_all
    Calendar.delete_all
    AcademicYear.delete_all

    ActiveRecord::Base.connection.reset_pk_sequence!('terms')
    ActiveRecord::Base.connection.reset_pk_sequence!('calendar_event_types')
    ActiveRecord::Base.connection.reset_pk_sequence!('calendar_event')
    ActiveRecord::Base.connection.reset_pk_sequence!('calendar')
    ActiveRecord::Base.connection.reset_pk_sequence!('academic_year')
    
    # Load Bank Holidays
    puts "Load bank holidays"
    Loader::BankHolidays.load!("etc/bank_holidays/england-and-wales.json")

    # Create calendar event types
    puts "Create Calendar Event Types"
    CalendarEventTypeFactory.create

    puts "Create academic years"
    AcademicYearFactory.new(1990, 2023).create

    # Load BANES calendar
    puts "Load banes calendar"
    Loader::Calendars.load!("etc/banes-default-calendar.csv", banes)

    puts "Load sheffield calendar"  
    Loader::Calendars.load!("etc/sheffield-default-calendar.csv", sheff)

    # Update schools to have BANES calendar as default
    puts "Update all schools to banes"
    School.all.update(calendar_area: banes)

    banes_calendar = Calendar.find_by!(template: true, area: banes)

    puts "Create calendars for enrolled schools"
    School.enrolled.each do |school|
      calendar = CalendarFactory.new(banes_calendar, school.name).create
      school.update(calendar: calendar)
    end

    # Create calendars based on banes calendar
    puts "Create DUMMY INSET DAY"
    inset_day_type = CalendarEventType.inset_day.find_by(school_occupied: true)
    banes_calendar.calendar_events.create(title: CalendarEventType::INSET_DAY, start_date: '2018-07-01', end_date: '2018-07-01', calendar_event_type: inset_day_type, academic_year: AcademicYear.find_by(start_date: '01-09-2018'))
  end
end
