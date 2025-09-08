FactoryBot.define do
  factory :newsletter do
    sequence(:title)  { |n| "Newsletter #{n}" }
    sequence(:url)    { |n| "https://example.com/#{n}" }
    published_on      { Date.parse('01/01/2019') }
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'images', 'laptop.jpg'), 'image/jpeg') }
    published { true }
  end
end
