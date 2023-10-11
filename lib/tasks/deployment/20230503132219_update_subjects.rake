namespace :after_party do
  desc 'Deployment task: update_subjects'
  task update_subjects: :environment do
    puts "Running deploy task 'update_subjects'"

    Subject.create(name: 'Expressive arts')
    Subject.create(name: 'Health and Well-being')

    Subject.find_by(name: 'Geography').update(name: 'Humanities')
    Subject.find_by(name: 'English').update(name: 'Languages, Literacy and Communication')
    Subject.find_by(name: 'Maths').update(name: 'Mathematics and Numeracy')
    Subject.find_by(name: 'Science').update(name: 'Science and Technology')

    d_and_t = Subject.find_by(name: 'Design and Technology')
    d_and_t.activity_types.each do |activity_type|
      activity_type.subjects.delete(d_and_t)
    end
    d_and_t.delete

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
