namespace :programmes do
  desc 'Enrol schools in default programme'
  task enrol_schools: [:environment] do
    puts "#{Time.zone.now} enrol_schools start"
    Programmes::Enroller.new.enrol_all
    puts "#{Time.zone.now} enrol_schools end"
  end
end
