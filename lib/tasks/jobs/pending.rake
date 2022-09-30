namespace :jobs do
  desc 'Return count of pending Delayed Jobs'
  task pending: [:environment] do
    # Note: Query matches that shown in delayed job web UI. See:
    # https://github.com/ejschmitt/delayed_job_web/blob/540f9e22525ef8ed85393df1d191616c9d75355b/lib/delayed_job_web/application/app.rb#L164
    puts Delayed::Job.where(attempts: 0, locked_at: nil).count
  end
end
