FactoryBot.define do
  factory :resource_file do
    resource_file_type
    sequence(:title)  { |n| "Resource #{n}" }
    file {  Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'images', 'newsletter-placeholder.png'), 'image/png') }
  end
end
