FactoryBot.define do
  factory :alert_error do
    alert_type
    asof_date { Date.today }
    information do
      'INVALID. Relevance: never_relevant'
    end
  end
end
