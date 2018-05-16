namespace :development do
  desc 'Load sample usage data for 3 schools'

  desc 'Load banes-default-calendar'
  task load_banes_default_calendar: [:environment] do
    england = Group.where(title: 'England and Wales').first_or_create
    group = Group.where(title: 'Bristol and North East Somerset (BANES)', parent_group: england).first_or_create
    Loader::Calendars.load!("etc/banes-default-calendar.csv", group)
  end

  desc 'Load sheffield-calendar'
  task load_sheffield_default_calendar: [:environment] do
    england = Group.where(title: 'England and Wales').first_or_create
    group = Group.where(title: 'Sheffield', parent_group: england).first_or_create
    Loader::Calendars.load!("etc/sheffield-default-calendar.csv", group)
  end
end
