class CalendarFactoryFromEventHash
  def initialize(event_hash, template_calendar, template = false, calendar_type = :regional)
    @event_hash = event_hash
    @template_calendar = template_calendar
    @template = template
    @calendar_type = calendar_type
  end

  def create
    @calendar = Calendar.where(calendar_type: @calendar_type, title: @template_calendar.title, based_on: @template_calendar).first_or_create!

    create_events_from_parent

    raise ArgumentError unless CalendarEventType.any?
    raise ArgumentError, "The calendar already has terms from it's parent: #{@template_calendar.title}" if @calendar.terms.any?

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
    @template_calendar.calendar_events.each do |calendar_event|
      @calendar.calendar_events.where(title: calendar_event.title, start_date: calendar_event.start_date, end_date: calendar_event.end_date, calendar_event_type: calendar_event.calendar_event_type).first_or_create!
    end
  end

  def create_holidays_between_terms
    HolidayFactory.new(@calendar).create
  end
end
