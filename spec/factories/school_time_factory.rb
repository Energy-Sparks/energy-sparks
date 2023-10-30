FactoryBot.define do
  trait :community_use_time do
    usage_type      { :community_use }
    calendar_period { :term_times }
  end

  trait :school_opening_time do
    usage_type        { :school_day }
    calendar_period   { :term_times }
  end

  factory :school_time, traits: [:school_opening_time] do
    school
    day             { :monday }
    opening_time    { 800 }
    closing_time    { 1600 }
  end

  factory :community_use, class: 'SchoolTime', traits: [:community_use_time] do
    school
    day             { :monday }
    opening_time    { 1800 }
    closing_time    { 2000 }
  end
end
