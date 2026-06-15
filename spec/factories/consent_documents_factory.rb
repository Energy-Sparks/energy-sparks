FactoryBot.define do
  factory :consent_document do
    school
    sequence(:title)        { |n| "Energy Bill #{n}"}
    sequence(:description)  { |n| "Description of bill #{n}"}
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'documents', 'fake-bill.pdf'), 'application/pdf')}
  end
end
