FactoryBot.define do
  factory :calendar_event do
    start_date  { 1.week.from_now }
    end_date    { 8.weeks.from_now }
    title       { 'new event' }
    description { 'this is a new event' }
    factory :term do
      title       { 'new term' }
      description { 'this is a new term' }
      association :calendar_event_type, term_time: true, holiday: false
    end
    factory :holiday do
      title       { 'new holiday' }
      description { 'this is a new holiday' }
      association :calendar_event_type, term_time: false, holiday: true
    end
    factory :bank_holiday_event  do
      title       { 'new holiday' }
      description { 'this is a new bank holiday event' }
      association :calendar_event_type, term_time: false, holiday: false, bank_holiday: false
    end
  end
end
