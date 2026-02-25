namespace :after_party do
  desc 'Deployment task: populate_school_groupings'
  task populate_school_groupings: :environment do
    puts "Running deploy task 'populate_school_groupings'"

    School.find_each do |school|
      next unless school.school_group_id.present?

      existing = SchoolGrouping.find_by(school_id: school.id, role: :organisation)

      if existing
        existing.update(school_group_id: school.school_group_id)
      else
        SchoolGrouping.create!(
          school_id: school.id,
          school_group_id: school.school_group_id,
          role: :organisation
        )
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
