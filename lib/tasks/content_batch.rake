namespace :content do
  desc "Validate readings"
  task batch: :environment do
    ContentBatch.new(School.all).generate
  end
end

