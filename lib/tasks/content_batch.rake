namespace :content do
  desc "Content batch"
  task batch: :environment do
    ContentBatchesJob.perform_later
  end
end
