class CalendarInitService
  def initialize(calendar)
    @calendar = calendar
  end

  def call
    @calendar.transaction do
      @calendar.calendar_events.where(based_on: nil).each do |calendar_event|
        if (parent_event = find_matching_event(@calendar.based_on, calendar_event))
          calendar_event.update!(based_on: parent_event)
        end
      end
    end
  rescue => e
    pp e.inspect
  end

  def find_matching_event(calendar, calendar_event)
    calendar.calendar_events.where(
      calendar_event_type: calendar_event.calendar_event_type,
      start_date: calendar_event.start_date,
      end_date: calendar_event.end_date
    ).first
  end
end
