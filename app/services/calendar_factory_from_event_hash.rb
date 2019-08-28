class CalendarFactoryFromEventHash
  def initialize(event_hash, area, template = false)
    @event_hash = event_hash
    @area = area
    @template = template
    @parent_calendar = parent_calendar
  end

  def create
    @calendar = Calendar.where(default: @template, calendar_area: @area, title: @area.title, template: @template, based_on: @parent_calendar).first_or_create!

    create_events_from_parent

    raise ArgumentError unless CalendarEventType.any?
    raise ArgumentError, "No parent/template calendar is set for this calendar area: #{@area.title}" if @parent_calendar.nil?
    raise ArgumentError, "The calendar already has terms from it's parent: #{@parent_calendar.title}" if @calendar.terms.any?

    @event_hash.each do |event|
      event_type = CalendarEventType.select { |cet| event[:term].include? cet.title }.first
      raise ArgumentError if event_type.nil?

      @calendar.calendar_events.where(title: event[:term], start_date: event[:start_date], end_date: event[:end_date], calendar_event_type: event_type).first_or_create!
    end

    create_holidays_between_terms
    @calendar
  end

private

  def create_events_from_parent
    @parent_calendar.calendar_events.each do |calendar_event|
      @calendar.calendar_events.where(title: calendar_event.title, start_date: calendar_event.start_date, end_date: calendar_event.end_date, calendar_event_type: calendar_event.calendar_event_type).first_or_create!
    end
  end

  def parent_calendar
    Calendar.find_by(calendar_area: @area, template: true) || Calendar.find_by(calendar_area: @area.parent_area, template: true)
  end

  def create_holidays_between_terms
    HolidayFactory.new(@calendar).create
  end
end
