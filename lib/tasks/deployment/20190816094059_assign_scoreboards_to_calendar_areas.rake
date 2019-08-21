namespace :after_party do
  desc 'Deployment task: assign_scoreboards_to_calendar_areas'
  task assign_scoreboards_to_calendar_areas: :environment do
    puts "Running deploy task 'assign_scoreboards_to_calendar_areas'"

    scotland = CalendarArea.find_by!(title: 'Scotland')
    england_and_wales = CalendarArea.find_by!(title: 'England and Wales')

    Scoreboard.where.not(name: 'Highland').update_all(calendar_area_id: england_and_wales.id)
    Scoreboard.where(name: 'Highland').update_all(calendar_area_id: scotland.id)

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
