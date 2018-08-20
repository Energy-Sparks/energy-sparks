require 'csv'

namespace :alerts do
  desc 'Run alerts job'
  task cron_job: [:environment] do
    puts Time.zone.now

    schools = School.enrolled
    schools.each do |school|
      AlertGeneratorService.new(school, Time.zone.today - 3.days).generate_for_contacts
    end
    puts Time.zone.now
  end
end
