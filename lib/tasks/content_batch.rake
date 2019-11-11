namespace :content do
  desc "Validate readings"
  task batch: :environment do
    ContentBatch.new(School.process_data).generate
  end
end
