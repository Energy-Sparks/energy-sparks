FactoryBot.define do
  factory :commercial_product, class: 'Commercial::Product' do
    sequence(:name) {|n| "Product #{n}"}
    sequence(:comments) {|n| "Product #{n} comments"}
    default_product { false }
    mat_price { 545.0 }
    large_school_price { 595.0 }
    small_school_price { 545.0 }
    size_threshold { 250 }
    private_account_fee { 95.0 }
    metering_fee { 25.0 }
    association :created_by, factory: :user
    association :updated_by, factory: :user

    trait :default_product do
      default_product { true }
    end
  end
end
