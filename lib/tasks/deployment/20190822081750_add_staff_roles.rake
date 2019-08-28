namespace :after_party do
  desc 'Deployment task: add_staff_roles'
  task add_staff_roles: :environment do
    puts "Running deploy task 'add_staff_roles'"

    ActiveRecord::Base.transaction do
      [
        'Business manager',
        'Building/site manager or caretaker',
        'Headteacher',
        'Governor',
        'Parent',
        'Teacher or teaching assistant',
        'LA or MAT advisor',
        'Third-party/other'
      ].each do |title|
        StaffRole.create!(
          title: title
        )
      end
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
