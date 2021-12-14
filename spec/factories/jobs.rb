FactoryBot.define do
  factory :job do
    sequence(:title)  { |n| "Job #{n}" }
    voluntary { false }
    closing_date { "2021-12-13" }
    file {  Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'images', 'newsletter-placeholder.png'), 'image/png') }
  end
end
