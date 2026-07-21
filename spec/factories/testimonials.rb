FactoryBot.define do
  factory :testimonial do
    active { true }
    category { :default }
    name { 'Testimonial name' }
    organisation { 'Testimonial organisation' }
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/images/pupils-jumping.jpg'), 'image/jpeg') }

    # Translated attributes
    sequence(:title_en) { |n| "Testimonial #{n} title in English" }
    sequence(:title_cy) { |n| "Testimonial #{n} title in English" }

    quote_en { 'Testimonial quote in English' }
    quote_cy { 'Testimonial quote in Welsh' }
    role_en { 'Testimonial role in English' }
    role_cy { 'Testimonial role in Welsh' }

    association :case_study, factory: :case_study
  end
end
