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

    schools = School.active
    schools.each do |school|
      puts "Running alerts for #{school.name}"
      run_for = Time.zone.today - 3.days
      AlertGeneratorService.new(school, run_for, run_for).generate_for_contacts(run_all)
    end
    puts Time.zone.now
  end
end
