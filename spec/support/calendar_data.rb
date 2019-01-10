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

  let(:area_and_calendar_title) { 'Area and Calendar title'}
  let!(:area) { create(:calendar_area, title: area_and_calendar_title) }
  let!(:academic_years) { AcademicYearFactory.new(2017, 2019).create }
  let!(:bank_holiday) { create :bank_holiday, title: 'Good Friday', holiday_date: "2012-04-06" }

  let!(:calendar_events) { CalendarEventTypeFactory.create }

  let(:autumn_term_half_term_holiday_start) { "2017-10-21" }
  let(:autumn_term_half_term_end)           { "2017-10-20" }

  let(:autumn_terms) {
    [{ term: "2017-18 Term 1", start_date: "2017-09-04", end_date: autumn_term_half_term_end },
     { term: "2017-18 Term 2", start_date: "2017-10-30", end_date: "2017-12-15" }]
  }
  let!(:calendar) { CalendarFactoryFromEventHash.new(autumn_terms, area).create }

  let(:random_before_holiday_start_date) { '01/01/2017' }
  let(:random_after_holiday_start_date)  { '16/12/2017' }

  let!(:random_before_holiday) {
    CalendarEvent.create(
      title: 'random holiday',
      calendar: calendar,
      calendar_event_type: CalendarEventType.holiday.first,
      start_date: random_before_holiday_start_date,
      end_date: '01/02/2017')}
  let!(:random_after_holiday) {
    CalendarEvent.create(
      title: 'random holiday 2',
      calendar: calendar,
      calendar_event_type: CalendarEventType.holiday.first,
      start_date: '16/12/2017',
      end_date: '20/12/2017')}
end

RSpec.configure do |rspec|
  rspec.include_context "calendar data", include_shared: true
end
