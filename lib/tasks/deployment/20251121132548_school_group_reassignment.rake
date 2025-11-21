namespace :after_party do
  desc 'Deployment task: school_group_reassignment'
  task school_group_reassignment: :environment do
    puts "Running deploy task 'school_group_reassignment'"

    def extract_slug(input)
      input.start_with?('http') ? input.split('/').last : nil
    end

    file_name = File.join(__dir__, 'school-group-reassignment.csv')
    CSV.foreach(file_name, headers: true) do |row|
      school_slug = extract_slug(row['School URL'])

      next unless school_slug

      school = School.find_by_slug(school_slug)
      next unless school

      school_group = SchoolGroup.find_by_slug(extract_slug(row['MAT/LA group URL']))
      next unless school_group

      if school_group
        school.school_group = school_group
        school.organisation_group = school_group
      end

      project_group = SchoolGroup.find_by_slug(extract_slug(row['Project URL']))
      school.project_groups << project_group if project_group
      school.save
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
