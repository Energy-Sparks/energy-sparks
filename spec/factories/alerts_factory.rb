FactoryBot.define do
  factory :alert do
    alert_type
    run_on { Date.today }
    rating 5.0
  end
end
