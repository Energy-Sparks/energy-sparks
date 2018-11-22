namespace :school_times do
  desc 'Set up school times'
  task setup: [:environment] do
    puts Time.zone.now
    School.all.each do |school|
      SchoolCreator.new(school).add_school_times!
    end
    puts Time.zone.now
  end
end
