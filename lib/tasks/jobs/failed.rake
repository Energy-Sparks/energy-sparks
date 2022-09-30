namespace :jobs do
  desc 'Return count of failed Delayed Jobs'
  task failed: [:environment] do
    # Note: Query matches that shown in delayed job web UI. See:
    # https://github.com/ejschmitt/delayed_job_web/blob/540f9e22525ef8ed85393df1d191616c9d75355b/lib/delayed_job_web/application/app.rb#L164
    puts Delayed::Job.where('last_error IS NOT NULL').count
  end
end
