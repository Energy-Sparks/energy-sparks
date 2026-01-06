FactoryBot.define do
  factory :audit do
    sequence(:title) {|n| "Audit #{n}"}
    school

    file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'documents', 'fake-bill.pdf'), 'application/pdf')}

    trait :with_todos do
      after(:create) do |audit, _evaluator|
        create_list(:activity_type_todo, 3, assignable: audit)
        create_list(:intervention_type_todo, 3, assignable: audit)
      end
    end
  end
end
