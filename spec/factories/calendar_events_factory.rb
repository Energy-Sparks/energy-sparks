FactoryBot.define do
  factory :calendar_event do
    start_date  { 1.week.from_now }
    end_date    { 8.weeks.from_now }
    description { 'this is a new event' }

    after(:build) do |object|
      if object.calendar && object.start_date
        AcademicYearFactory.new(object.calendar).create(
          start_year: object.start_date.year - 1,
          end_year: object.start_date.year + 1
        )
      end
    end

    factory :term do
      description { 'this is a new term' }
      association :calendar_event_type, term_time: true, holiday: false, title: 'Term 1'
    end
    factory :calendar_event_holiday do
      description { 'this is a new holiday' }
      association :calendar_event_type, term_time: false, holiday: true, analytics_event_type: :school_holiday, title: 'Holiday'
    end
    factory :bank_holiday do
      description { 'this is a new bank holiday event' }
      association :calendar
      association :calendar_event_type, term_time: false, holiday: false, bank_holiday: true, analytics_event_type: :bank_holiday, title: 'Bank Holiday'
    end
    factory :inset_day do
      description { 'this is a new inset day event' }
      association :calendar
      association :calendar_event_type, term_time: false, holiday: false, bank_holiday: false, inset_day: true, analytics_event_type: :inset_day_in_school, title: 'In school Inset Day'
    end
  end
end
