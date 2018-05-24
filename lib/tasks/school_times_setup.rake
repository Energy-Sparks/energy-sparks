namespace :school_times do
  desc 'Set up school times'
  task setup: [:environment] do
    puts Time.zone.now
    School.all.each do |school|
      SchoolTime.days.each do |day, _value|
        school.school_times.create(day: day)
      end
    end
    puts Time.zone.now
  end
end
