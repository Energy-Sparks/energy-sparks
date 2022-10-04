namespace :content do
  desc "Content batch"
  task batch: :environment do
    Rails.cache.clear
    ContentBatchJob.perform_later
  end
end
