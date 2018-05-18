class HolidayFactory
  def initialize(calendar)
    @calendar = calendar
  end

  def build
    holiday_type = CalendarEventType.where(title: 'Holiday', holiday: true, colour: 'rgb(68, 183, 62)', school_occupied: false, term_time: false).first_or_create
    events = @calendar.calendar_events
    terms = events.eager_load(:calendar_event_type).where('calendar_event_types.term_time = true').order(start_date: :asc)

    terms.each_with_index do |term, index|
      # pp term.title
      # pp terms[index + 1].title
      # pp index
      next_term = terms[index + 1]
      next if next_term.nil?
      pp "create holiday for #{term.end_date} #{next_term.start_date}"
      CalendarEvent.where(calendar: @calendar, calendar_event_type: holiday_type, start_date: term.end_date, end_date: next_term.start_date).first_or_create
    end
  end
end
