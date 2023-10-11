class CalendarResetService
  def initialize(calendar)
    @calendar = calendar
  end

  def reset
    calendar_types = (CalendarEventType.holiday + CalendarEventType.term + CalendarEventType.bank_holiday)
    CalendarEvent.transaction do
      @calendar.calendar_events.where(calendar_event_type: calendar_types).destroy_all
      if @calendar.based_on
        @calendar.based_on.calendar_events.where(calendar_event_type: calendar_types).find_each do |calendar_event|
          child_event = calendar_event.dup
          child_event.based_on = calendar_event
          @calendar.calendar_events << child_event
        end
      end
    end
  end
end
