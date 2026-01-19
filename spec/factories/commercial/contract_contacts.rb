FactoryBot.define do
  factory :commercial_contract_contact, class: 'Commercial::ContractContact' do
    sequence(:name) {|n| "Contract Name #{n}"}
    sequence(:email) { |n| "user_#{n}@test.com" }
    sequence(:comments) {|n| "Contract #{n} comments"}
    association :contract_holder, factory: :funder

    contact_type { :procurement }

    association :created_by, factory: :user
    association :updated_by, factory: :user

    trait :with_user do
      user
    end

    trait :for_school do
      contract_holder { association :school }
    end

    trait :for_school_group do
      contract_holder { association :school_group }
    end
  end
end
