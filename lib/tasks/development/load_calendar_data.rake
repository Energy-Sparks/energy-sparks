namespace :development do
  desc 'Load sample usage data for 3 schools'

  desc 'Load banes-default-calendar'
  task load_banes_default_calendar: [:environment] do
   # Calendar.where(name: "Default Calendar", default: true).first_or_create
    Loader::Calendars.load!("etc/banes-default-calendar.csv")
  end
end
