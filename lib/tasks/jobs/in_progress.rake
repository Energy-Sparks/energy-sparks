namespace :jobs do
  desc 'Return count of Delayed Jobs in progress '
  task in_progress: [:environment] do
    puts Delayed::Job.where('locked_at IS NOT NULL AND failed_at IS NULL').count
  end
end
