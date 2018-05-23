namespace :development do
  desc 'Load sample usage data for 3 schools'

  desc 'Load banes-default-calendar'
  task load_banes_default_calendar: [:environment] do
    england = CalendarArea.where(title: 'England and Wales').first_or_create
    area = ArCalendarAreaea.where(title: 'Bath and North East Somerset (BANES)', parent_calendar_area: england).first_or_create
    Loader::Calendars.load!("etc/banes-default-calendar.csv", area)
  end

  desc 'Load sheffield-calendar'
  task load_sheffield_default_calendar: [:environment] do
    england = CalendarArea.where(title: 'England and Wales').first_or_create
    area = CalendarArea.where(title: 'Sheffield', parent_calendar_area: england).first_or_create
    Loader::Calendars.load!("etc/sheffield-default-calendar.csv", area)
  end
end
