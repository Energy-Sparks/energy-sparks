class CalendarResetService
  def initialize(calendar)
    @calendar = calendar
  end

  def reset
    calendar_types = (CalendarEventType.holiday + CalendarEventType.term + CalendarEventType.bank_holiday)
    CalendarEvent.transaction do
      @calendar.calendar_events.where(calendar_event_type: calendar_types).destroy_all
      if @calendar.based_on
        @calendar.based_on.calendar_events.where(calendar_event_type: calendar_types).each do |calendar_event|
          @calendar.calendar_events << calendar_event.dup
        end
      end
    end
  end
end
