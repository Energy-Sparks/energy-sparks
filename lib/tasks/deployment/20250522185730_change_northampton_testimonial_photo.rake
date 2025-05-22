namespace :after_party do
  desc 'Deployment task: change_northampton_testimonial_photo'
  task change_northampton_testimonial_photo: :environment do
    puts "Running deploy task 'change_northampton_testimonial_photo'"

    testimonial = Testimonial.find_by(name: 'David Reed')

    testimonial.image.attach(io: File.open(Rails.root.join('app/assets/images/Northampton-Academy.jpg')), filename: 'Northampton-Academy.jpg')
    testimonial.save!
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
