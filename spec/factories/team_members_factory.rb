FactoryBot.define do
  factory :team_member do
    sequence(:title)  { |n| "Team member #{n}" }
    image {  Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'images', 'newsletter-placeholder.png'), 'image/png') }
  end
end

