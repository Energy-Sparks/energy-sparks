namespace :after_party do
  desc 'Deployment task: gdst_pupil_number_update'
  task gdst_pupil_number_update: :environment do
    puts "Running deploy task 'gdst_pupil_number_update'"

    csv_path = File.join(__dir__, '2025-10-16-gdst-pupil-numbers.csv')

    CSV.foreach(csv_path, headers: true) do |row|
      slug = row['ID']
      pupil_count = row['Pupil Numbers'].to_i

      school = School.find_by(slug: slug)

      if school
        Schools::PupilNumberUpdater.new(school).update(pupil_count, 'Update from CSV')
        puts "Updated #{school.name} (#{slug}) to #{pupil_count} pupils"
      else
        puts "School not found for slug: #{slug}"
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
