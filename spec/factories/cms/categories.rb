FactoryBot.define do
  factory :category, class: 'Cms::Category' do
    sequence(:title) {|n| "Category #{n}"}
    sequence(:description) {|n| "Category #{n} description"}
    published { false }
    icon { 'lightbulb' }

    trait :with_pages do
      transient do
        count { 1 }
        pages_published { true }
      end

      after(:create) do |category, evaluator|
        create_list(:page, evaluator.count, category: category, published: evaluator.pages_published)
      end
    end
  end
end
