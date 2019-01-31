FactoryBot.define do
  factory :alert do
    alert_type
    run_on { Date.today }
    sequence(:summary) {|n| "Alert #{n}"}
  end
end
