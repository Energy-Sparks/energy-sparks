namespace :content do
  desc "Validate readings"
  task batch: :environment do
    Rails.cache.clear
    ContentBatch.new(School.process_data.order(:name)).generate
  end
end
