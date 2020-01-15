FactoryBot.define do
  factory :case_study do
    sequence(:title)  { |n| "Case study #{n}" }
    file {  Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'images', 'newsletter-placeholder.png'), 'image/png') }
  end
end
