FactoryBot.define do
  factory :user_tariff do
    sequence(:name) {|n| "User Tariff #{n}"}
    start_date { '2018-01-01' }
    end_date { '2018-12-31' }
    fuel_type { :gas }
    school
  end
end
