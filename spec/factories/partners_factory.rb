FactoryBot.define do
  factory :partner do
    sequence(:name) {|n| "Partner #{n}"}
    image {  Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'images', 'newsletter-placeholder.png'), 'image/png') }
  end
end
