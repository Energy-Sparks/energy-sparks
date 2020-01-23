namespace :after_party do
  desc 'Deployment task: update_freshford_rooms'
  task update_freshford_rooms: :environment do
    puts "Running deploy task 'update_freshford_rooms'"

    school = School.find('freshford-church-school')

    [['George class', 'Gorge class'], ['Server room', 'iPad room'], ['By the sea', 'by the sea'], ['Library', 'Libray']].each do |correct_name, incorrect_name|

      puts "Correcting #{incorrect_name} to #{correct_name}"
      correct_location = school.locations.find_by!(name: correct_name)
      incorrect_location = school.locations.find_by!(name: incorrect_name)

      incorrect_location.temperature_recordings.update_all(location_id: correct_location.id)
      incorrect_location.destroy!
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
