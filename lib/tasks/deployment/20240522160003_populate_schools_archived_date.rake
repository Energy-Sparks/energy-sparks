namespace :after_party do
  desc 'Deployment task: populate_schools_archived_date'
  task populate_schools_archived_date: :environment do
    puts "Running deploy task 'populate_schools_archived_date'"

    archived_schools = School.inactive.where(removal_date: nil)
    wiltshire_school_group = SchoolGroup.find('wiltshire')
    # swansea_school_group = SchoolGroup.find('swansea')

    archived_schools.each do |school|
      if school.school_group == wiltshire_school_group
        school.update(archived_date: '2024-01-31')
      #elsif school.school_group == sweansea_school_group
        ## claudia to provide a list
      else
        school.update(archived_date: '2023-08-31')
      end
    end

    # Put your task implementation HERE.

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end