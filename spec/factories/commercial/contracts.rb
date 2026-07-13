# frozen_string_literal: true

FactoryBot.define do
  factory :commercial_contract, class: 'Commercial::Contract' do
    sequence(:name) { |n| "Contract #{n}" }
    sequence(:comments) { |n| "Contract #{n} comments" }

    number_of_schools { 100 }
    licence_years { 1.0 }

    start_date { Time.zone.today }
    end_date { Time.zone.today + 364 }

    contract_holder factory: %i[funder]
    product factory: %i[commercial_product]
    created_by factory: %i[user]
    updated_by factory: %i[user]
    xero_account_code factory: %i[commercial_xero_account_code]

    trait :custom do
      licence_period { :custom }
      invoice_terms { :full }
    end

    trait :with_school do
      contract_holder { association :school }
    end

    trait :with_school_group do
      contract_holder { association :school_group }
    end

    trait :with_funder do
      contract_holder { association :funder }
    end

    trait :expired do
      start_date { Time.zone.today - 1.year }
      end_date { Time.zone.yesterday }
    end

    trait :future do
      start_date { Time.zone.today + 7.days }
      end_date { start_date + 364 }
    end
  end
end
