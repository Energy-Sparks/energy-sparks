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

  EXAMPLE_CALENDAR_HASH = [{:term=>"2015-16 Term 1", :start_date=>"2015-09-02", :end_date=>"2015-10-21"}, {:term=>"2015-16 Term 2", :start_date=>"2015-11-02", :end_date=>"2015-12-18"}, {:term=>"2015-16 Term 3", :start_date=>"2016-01-04", :end_date=>"2016-02-12"}, {:term=>"2015-16 Term 4", :start_date=>"2016-02-22", :end_date=>"2016-04-01"}, {:term=>"2015-16 Term 5", :start_date=>"2016-04-18", :end_date=>"2016-05-27"}, {:term=>"2015-16 Term 6", :start_date=>"2016-06-06", :end_date=>"2016-07-19"}, {:term=>"2016-17 Term 1", :start_date=>"2016-09-01", :end_date=>"2016-10-21"}, {:term=>"2016-17 Term 2", :start_date=>"2016-10-31", :end_date=>"2016-12-16"}, {:term=>"2016-17 Term 3", :start_date=>"2017-01-03", :end_date=>"2017-02-10"}, {:term=>"2016-17 Term 4", :start_date=>"2017-02-20", :end_date=>"2017-04-07"}, {:term=>"2016-17 Term 5", :start_date=>"2017-04-24", :end_date=>"2017-05-26"}, {:term=>"2016-17 Term 6", :start_date=>"2017-06-05", :end_date=>"2017-07-21"}, {:term=>"2017-18 Term 1", :start_date=>"2017-09-04", :end_date=>"2017-10-20"}, {:term=>"2017-18 Term 2", :start_date=>"2017-10-30", :end_date=>"2017-12-15"}, {:term=>"2017-18 Term 3", :start_date=>"2018-01-02", :end_date=>"2018-02-09"}, {:term=>"2017-18 Term 4", :start_date=>"2018-02-19", :end_date=>"2018-03-23"}, {:term=>"2017-18 Term 5", :start_date=>"2018-04-09", :end_date=>"2018-05-25"}, {:term=>"2017-18 Term 6", :start_date=>"2018-06-04", :end_date=>"2018-07-24"}, {:term=>"2018-19 Term 1", :start_date=>"2018-09-03", :end_date=>"2018-10-26"}, {:term=>"2018-19 Term 2", :start_date=>"2018-11-05", :end_date=>"2018-12-21"}, {:term=>"2018-19 Term 3", :start_date=>"2019-01-07", :end_date=>"2019-02-15"}, {:term=>"2018-19 Term 4", :start_date=>"2019-02-25", :end_date=>"2019-04-05"}, {:term=>"2018-19 Term 5", :start_date=>"2019-04-23", :end_date=>"2019-05-24"}, {:term=>"2018-19 Term 6", :start_date=>"2019-06-03", :end_date=>"2019-07-23"}].freeze


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
