namespace :after_party do
  desc 'Deployment task: update_front_page_testimonial'
  task update_front_page_testimonial: :environment do
    puts "Running deploy task 'update_front_page_testimonial'"

    testimonial = Testimonial.find_or_initialize_by(name: 'David Reed')

    testimonial.update(
      quote: 'The main thing for me was: don’t assume the heating settings are right without checking; take time to have a look, as it is worth it for everyone.',
      title: 'Energy Sparks helped Northampton Academy reduce energy costs by 40% in their first year',
      name: 'David Reed',
      role: 'Facilities Manager',
      organisation: 'Northampton Academy',
      case_study_id: 15,
      active: true
    )

    testimonial.image.attach(io: File.open(Rails.root.join('app/assets/images/boiler.jpg')), filename: 'boiler.jpg')
    testimonial.save!

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
