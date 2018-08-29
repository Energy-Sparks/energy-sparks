require 'csv'

namespace :alerts do
  desc 'Run alerts job'
  task cron_job: [:environment] do
    do_the_job
  end

  task cron_job_run_all: [:environment] do
    do_the_job(true)
  end

  def do_the_job(run_all = false)
    puts Time.zone.now

    schools = School.enrolled
    schools.each do |school|
      puts "Running alerts for #{school.name}"
      AlertGeneratorService.new(school, Time.zone.today - 3.days).generate_for_contacts(run_all)
    end
    puts Time.zone.now
  end
end
