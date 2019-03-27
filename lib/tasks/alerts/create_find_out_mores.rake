namespace :alerts do
  desc 'Run find out more job'
  task create_find_out_mores: [:environment] do
    puts Time.zone.now
    schools = School.active
    schools.each do |school|
      puts "Running find out mores for #{school.name}"
      Alerts::GenerateFindOutMores.new(school).perform
    end
    puts Time.zone.now
  end
end
