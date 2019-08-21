FactoryBot.define do
  factory :calendar_event do
    start_date  { 1.week.from_now }
    end_date    { 8.weeks.from_now }
    title       { 'new event' }
    description { 'this is a new event' }

    after(:build) do |object|
      if object.calendar && object.calendar.calendar_area && object.start_date
        AcademicYearFactory.new(object.calendar.calendar_area).create(
          start_year: object.start_date.year - 1,
          end_year: object.start_date.year + 1
        )
      end
    end

    factory :term do
      title       { 'new term' }
      description { 'this is a new term' }
      association :calendar_event_type, term_time: true, holiday: false
    end
    factory :holiday do
      title       { 'new holiday' }
      description { 'this is a new holiday' }
      association :calendar_event_type, term_time: false, holiday: true, analytics_event_type: :school_holiday
    end
    factory :bank_holiday_event  do
      title       { 'new holiday' }
      description { 'this is a new bank holiday event' }
      association :calendar_event_type, term_time: false, holiday: false, bank_holiday: false, analytics_event_type: :bank_holiday
    end
  end
end
