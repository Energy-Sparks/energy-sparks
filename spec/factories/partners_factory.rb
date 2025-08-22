FactoryBot.define do
  factory :partner do
    sequence(:name) {|n| "Partner #{n}"}
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'images', 'newsletter-placeholder.png'), 'image/png') }
    sequence(:url) {|n| "https://example.org/#{n}" }
  end
end
