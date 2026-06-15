FactoryBot.define do
  factory :page, class: 'Cms::Page' do
    category
    sequence(:title) {|n| "Page #{n}"}
    sequence(:description) {|n| "Page #{n} body"}
    # sequence(:audience)  {|n| "Page #{n} audience"}
    published { false }

    trait :with_sections do
      transient do
        count { 1 }
        sections_published { true }
      end

      after(:create) do |page, evaluator|
        create_list(:section, evaluator.count, page: page, published: evaluator.sections_published)
      end
    end
  end
end
