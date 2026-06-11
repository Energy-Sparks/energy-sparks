# frozen_string_literal: true

FactoryBot.define do
  factory :commercial_contract_contact, class: 'Commercial::ContractContact' do
    sequence(:name) { |n| "Contract Name #{n}" }
    sequence(:email) { |n| "user_#{n}@test.com" }
    sequence(:comments) { |n| "Contract #{n} comments" }
    contract_holder factory: %i[funder]

    contact_type { :procurement }

    created_by factory: %i[user]
    updated_by factory: %i[user]

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
