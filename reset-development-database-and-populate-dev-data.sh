rake db:drop db:create

rake db:migrate VERSION=20180508114132
rake db:seed

RAILS_ENV=test rake db:setup

rake loader:import_activities"[etc/banes-default-activities.csv]"
rake loader:import_activity_progression"[etc/banes_activity_progression.csv]"

rake development:load_banes_default_calendar

rake loader:import_schools"[etc/banes-eligible-schools.csv]"

rake db:migrate
rake db:migrate RAILS_ENV=test

rake development:active_freshford_with_meters
rake loader:import_school_readings"[2018-05-01]"
