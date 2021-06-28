namespace :content do
  desc "Content batch"
  task batch: :environment do
    puts "#{DateTime.now.utc} Content batch start"
    Rails.cache.clear
    ContentBatch.new(School.process_data.order(:name)).generate
    puts "#{DateTime.now.utc} Content batch end"
  end
end
