# rubocop:disable Metrics/BlockLength
namespace :after_party do
  desc 'Deployment task: school_group_reassignment'
  task school_group_reassignment: :environment do
    puts "Running deploy task 'school_group_reassignment'"

    def extract_slug(input)
      return nil unless input
      input.start_with?('http') ? input.split('/').last : nil
    end

    file_name = File.join(__dir__, 'school-group-reassignment.csv')
    CSV.foreach(file_name, headers: true) do |row|
      school_name = row['School name']
      school_slug = extract_slug(row['School URL'])

      group_slug = extract_slug(row['MAT/LA group URL'])
      project_slug = extract_slug(row['Project URL'])

      project_group = SchoolGroup.find_by_slug(project_slug)
      puts "Unable to find project group #{project_slug}" unless project_group

      if school_slug
        school = School.find_by_slug(school_slug)
        puts "Unable to find school #{school_name} using #{school_slug}, skipping" unless school
        next unless school

        school_group = SchoolGroup.find_by_slug(group_slug)
        puts "Unable to find school group #{group_slug}, skipping all updates" unless school_group
        next unless school_group

        if school_group
          school.school_group = school_group
          school.organisation_group = school_group
        end

        school.project_groups = [project_group] if project_group

        school.save
      else
        school_onboarding = SchoolOnboarding.find_by_school_name(school_name)

        puts "Unable to find onboarding for #{school_name}, skipping" unless school_onboarding
        next unless school_onboarding

        school_onboarding.project_group = project_group if project_group
        school_onboarding.save
      end
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
# rubocop:enable Metrics/BlockLength
