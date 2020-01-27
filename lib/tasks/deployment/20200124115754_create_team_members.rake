namespace :after_party do
  desc 'Deployment task: create_team_members'
  task create_team_members: :environment do
    puts "Running deploy task 'create_team_members'"

    # Put your task implementation HERE.


    TeamMember.transaction do

      team_member_1 = TeamMember.new(
        position: 1,
        title: 'Philip Haile',
        description: 'Project Lead, Energy Expert',
      )
      file_name = 'ph.jpg'
      team_member_1.image.attach(io: File.open(Rails.root.join("app/assets/images/team/#{file_name}")), filename: file_name, content_type: 'image/jpeg')
      team_member_1.save!

      team_member_2 = TeamMember.new(
        position: 2,
        title: 'Claudia Towner',
        description: 'Project Manager and School Liaison',
      )
      file_name = 'ct.jpg'
      team_member_2.image.attach(io: File.open(Rails.root.join("app/assets/images/team/#{file_name}")), filename: file_name, content_type: 'image/jpeg')
      team_member_2.save!

      team_member_3 = TeamMember.new(
        position: 3,
        title: 'James Jefferies',
        description: 'Technologist',
      )
      file_name = 'jj.jpg'
      team_member_3.image.attach(io: File.open(Rails.root.join("app/assets/images/team/#{file_name}")), filename: file_name, content_type: 'image/jpeg')
      team_member_3.save!

      team_member_4 = TeamMember.new(
        position: 4,
        title: 'James Almond',
        description: 'Technologist',
      )
      file_name = 'ja.jpg'
      team_member_4.image.attach(io: File.open(Rails.root.join("app/assets/images/team/#{file_name}")), filename: file_name, content_type: 'image/jpeg')
      team_member_4.save!

      team_member_5 = TeamMember.new(
        position: 5,
        title: 'Paula Malone',
        description: 'Project Administrator and School Support',
      )
      file_name = 'pm.jpg'
      team_member_5.image.attach(io: File.open(Rails.root.join("app/assets/images/team/#{file_name}")), filename: file_name, content_type: 'image/jpeg')
      team_member_5.save!
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
