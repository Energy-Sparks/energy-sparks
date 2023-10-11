class CalendarTermFactory
  def initialize(calendar, term_hash)
    @calendar = calendar
    @term_hash = term_hash
  end

  def create_terms
    @term_hash.each do |event|
      event_type = CalendarEventType.select { |cet| event[:term].include? cet.title }.first
      raise ArgumentError if event_type.nil?

      @calendar.calendar_events.where(start_date: event[:start_date], end_date: event[:end_date], calendar_event_type: event_type).first_or_create!
    end

    create_holidays_between_terms
  end

  private

  def create_holidays_between_terms
    HolidayFactory.new(@calendar).create
  end
end
