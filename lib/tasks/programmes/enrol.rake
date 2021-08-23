namespace :programmes do
  desc 'Enrol schools in default programme'
  task enrol_schools: [:environment] do
    puts "#{Time.zone.now} Enrolling schools"
    Programmes::Enroller.new.enrol_all
    puts "#{Time.zone.now} Finished enrolling schools"
  end
end
