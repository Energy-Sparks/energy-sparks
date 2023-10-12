FactoryBot.define do
  factory :alert_error do
    alert_type
    asof_date { Time.zone.today }
    information {
      'INVALID. Relevance: never_relevant'
    }
  end
end
