namespace :after_party do
  desc 'Deployment task: update_audits_testimonial'
  task update_audits_testimonial: :environment do
    puts "Running deploy task 'update_audits_testimonial'"

    testimonial = Testimonial.find_or_initialize_by(name: 'Mark Crookes')

    testimonial.update(
      quote: 'Very detailed, knowledgeable, involved students really well, wealth of experience.',
      title: 'Energy Sparks audit helped Mallaig High School reduce energy use by 38% and save around £3,400 compared with the previous year',
      role: 'Teacher',
      organisation: 'Mallaig High School, Highlands',
      case_study_id: 9,
      category: :audit,
      active: true
    )

    testimonial.image.attach(io: File.open(Rails.root.join('app/assets/images/Mallaig-High.png')), filename: 'Mallaig-High.png')
    testimonial.save!
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
