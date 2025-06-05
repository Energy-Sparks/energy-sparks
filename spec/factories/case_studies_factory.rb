FactoryBot.define do
  factory :case_study do
    sequence(:title)  { |n| "Case study #{n}" }
    sequence(:description) { |n| "Description for case study #{n}" }
    file_en { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'images', 'newsletter-placeholder.png'), 'image/png') }
    tags { 'tag one, tag two, tag three' }
    published { true }
    position { 1 }
  end
end
