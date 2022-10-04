namespace :content do
  desc "Content batch"
  task batch: :environment do
    ContentBatchJob.perform_later
  end
end
