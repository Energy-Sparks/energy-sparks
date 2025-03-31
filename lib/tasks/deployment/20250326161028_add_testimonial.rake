namespace :after_party do
  desc 'Deployment task: add_testimonial'
  task add_testimonial: :environment do
    puts "Running deploy task 'add_testimonial'"

    exists = Testimonial.find_by(name: 'David Reed')

    if exists.nil?
      testimonial = Testimonial.new(
        quote: 'The main thing for me was: don’t assume the heating settings are right without checking; take time to have a look, as it is worth it for everyone',
        title: 'Energy Sparks helped Northampton Academy reduce energy costs by 40% and £34,000 in their first year',
        name: 'David Reed',
        role: 'Facilities Manager',
        organisation: 'Northampton Academy',
        case_study_id: 15,
        active: true
      )
      testimonial.image.attach(io: File.open(Rails.root.join('app/assets/images/funnel-pupils.png')), filename: 'laptop.jpg')
      testimonial.save!
    end

    # Put your task implementation HERE.

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end