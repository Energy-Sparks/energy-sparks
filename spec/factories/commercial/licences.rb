# frozen_string_literal: true

FactoryBot.define do
  factory :commercial_licence, class: 'Commercial::Licence' do
    school
    contract factory: %i[commercial_contract]

    sequence(:comments) { |n| "Licence #{n} comments" }

    start_date { Time.zone.today }
    end_date { Time.zone.today + 364 }

    created_by factory: %i[user]
    updated_by factory: %i[user]

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
