class CalendarFactoryFromEventHash
  def initialize(event_hash, area, template = false)
    @event_hash = event_hash
    @area = area
    @template = template
    @parent_calendar = parent_calendar
  end

  def create
    @calendar = Calendar.where(default: @template, calendar_area: @area, title: @area.title, template: @template).first_or_create!

    raise ArgumentError unless CalendarEventType.any?
    raise ArgumentError, "No parent/template calendar is set for this calendar area: #{@area.title}" if @parent_calendar.nil?

    @event_hash.each do |event|
      event_type = CalendarEventType.select { |cet| event[:term].include? cet.title }.first
      raise ArgumentError if event_type.nil?

      @calendar.calendar_events.where(title: event[:term], start_date: event[:start_date], end_date: event[:end_date], calendar_event_type: event_type).first_or_create!
    end

    create_bank_holidays
    create_holidays_between_terms
    @calendar
  end

private

  def parent_calendar
    Calendar.find_by(calendar_area: @area, template: true) || Calendar.find_by(calendar_area: @area.parent_area, template: true)
  end

  def create_holidays_between_terms
    HolidayFactory.new(@calendar).create
  end

  def create_bank_holidays
    bank_holiday = CalendarEventType.bank_holiday.first

    @parent_calendar.bank_holidays.each do |bh|
      @calendar.calendar_events.where(title: bh.title, start_date: bh.start_date, end_date: bh.end_date, calendar_event_type: bank_holiday).first_or_create!
    end
  end
end
