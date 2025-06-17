FactoryBot.define do
  factory :case_study do
    sequence(:title_en) { |n| "Case study #{n}" }
    sequence(:description_en) { |n| "Description for case study #{n}" }
    image { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'images', 'laptop.jpg'), 'image/jpeg') }
    file_en { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'documents', 'fake-bill.pdf'), 'application/pdf')}
    tags { 'tag one, tag two, tag three' }
    published { true }
    position { 1 }
  end
end
