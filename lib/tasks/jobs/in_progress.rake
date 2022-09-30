namespace :jobs do
  desc 'Return count of Delayed Jobs in progress '
  task in_progress: [:environment] do
    # Note: Query matches that shown in delayed job web UI. See:
    # https://github.com/ejschmitt/delayed_job_web/blob/540f9e22525ef8ed85393df1d191616c9d75355b/lib/delayed_job_web/application/app.rb#L164
    puts Delayed::Job.where('locked_at IS NOT NULL AND failed_at IS NULL').count
  end
end
