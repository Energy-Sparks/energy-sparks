# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 1.day, :at => '6:00 am' do
  rake "loader:read_meters"
end

every :saturday, at: '12am' do
  rake 'merit:weekly_energy_reduction'
  rake 'merit:electricity_reduction'
  rake 'merit:gas_reduction'
  rake 'merit:activity_per_week'
end
