FactoryBot.define do
  factory :calendar_event_type do
    trait :holiday do
      holiday { true }
      analytics_event_type { :school_holiday }
    end
    trait :term_time do
      term_time { true }
      analytics_event_type { :term_time }
    end
    trait :bank_holiday do
      bank_holiday { true }
      analytics_event_type { :bank_holiday }
    end
    trait :inset_day_in_school do
      inset_day { true }
      school_occupied { true }
      analytics_event_type { :inset_day_in_school }
    end
    trait :inset_day_out_of_school do
      inset_day { true }
      school_occupied { false }
      analytics_event_type { :inset_day_out_of_school }
    end
  end
end
