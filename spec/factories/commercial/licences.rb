FactoryBot.define do
  factory :commercial_licence, class: 'Commercial::Licence' do
    school
    association :contract, factory: :commercial_contract

    start_date { Time.zone.today }
    end_date { Time.zone.today + 1.year }

    association :created_by, factory: :user
    association :updated_by, factory: :user

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
