RSpec.configure do |rspec|
  # This config option will be enabled by default on RSpec 4,
  # but for reasons of backwards compatibility, you have to
  # set it on RSpec 3.
  #
  # It causes the host group and examples to inherit metadata
  # from the shared context.
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context "calendar data", shared_context: :metadata do
  let!(:calendar_events) { create_all_calendar_events }

  let(:autumn_term_half_term_holiday_start) { "2017-10-21" }
  let(:autumn_term_half_term_end)           { "2017-10-20" }

  let(:autumn_terms) do
    [{ term: "2017-18 Term 1", start_date: "2017-09-04", end_date: autumn_term_half_term_end },
     { term: "2017-18 Term 2", start_date: "2017-10-30", end_date: "2017-12-15" }]
  end

  let!(:parent_template_calendar) { create(:regional_calendar) }
  let!(:academic_year) { create(:academic_year, calendar: parent_template_calendar, start_date: '2016-09-01', end_date: '2017-08-30')}
  let!(:academic_year_2) { create(:academic_year, calendar: parent_template_calendar, start_date: '2017-09-01', end_date: '2018-08-30')}

  let!(:bank_holiday) { create :bank_holiday, calendar: parent_template_calendar, start_date: "2012-04-06", end_date: "2012-04-06" }
  let!(:calendar) do
    cal = CalendarFactory.new(existing_calendar: parent_template_calendar, title: 'calendar title').create
    CalendarTermFactory.new(cal, autumn_terms).create_terms
    cal.reload
    cal
  end

  let(:random_before_holiday_start_date) { '01/01/2017' }
  let(:random_after_holiday_start_date)  { '16/12/2017' }

  let!(:random_before_holiday) do
    CalendarEvent.create!(
      calendar: calendar,
      calendar_event_type: CalendarEventType.holiday.first,
      start_date: random_before_holiday_start_date,
      end_date: '01/02/2017')
  end
  let!(:random_after_holiday) do
    CalendarEvent.create!(
      calendar: calendar,
      calendar_event_type: CalendarEventType.holiday.first,
      start_date: '16/12/2017',
      end_date: '20/12/2017')
  end
end

RSpec.configure do |rspec|
  rspec.include_context "calendar data", include_shared: true
end
