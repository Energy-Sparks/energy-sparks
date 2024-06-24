namespace :after_party do
  desc 'Deployment task: change_school_funder'
  task change_school_funder: :environment do
    puts "Running deploy task 'change_school_funder'"

    SchoolGroup.find_each do |school_group|
      next if school_group.funder.nil?

      school_group.schools.find_each do |school|
        next unless school.funder.nil?

        puts "Updating funder for school #{school.id}"
        school.funder = school_group.funder
        school.save
      end
    end

    # Put your task implementation HERE.

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
