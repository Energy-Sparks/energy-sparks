FactoryBot.define do
  factory :commercial_contract, class: 'Commercial::Contract' do
    sequence(:name) {|n| "Contract #{n}"}
    sequence(:comments) {|n| "Contract #{n} comments"}

    number_of_schools { 100 }

    start_date { Time.zone.today }
    end_date { Time.zone.today + 1.year }

    association :contract_holder, factory: :funder
    association :product, factory: :commercial_product
    association :created_by, factory: :user
    association :updated_by, factory: :user

    trait :with_school do
      contract_holder { association :school }
    end

    trait :with_school_group do
      contract_holder { association :school_group }
    end

    trait :historical do
      start_date { Time.zone.today - 1.year }
      end_date { Time.zone.yesterday }
    end

    trait :future do
      start_date { Time.zone.today + 7.days }
      end_date { start_date + 1.year }
    end
  end
end
