class CalendarResyncService
  def initialize(calendar)
    @calendar = calendar
  end

  def resync
    calendar_events = calendar_events_to_sync(@calendar)
    @calendar.calendars.each do |child_calendar|
      child_calendar.transaction do
        resync_child_events(calendar_events, child_calendar)
      end
    end
  end

  def resync_child_events(calendar_events, child_calendar)
    child_calendar.calendar_events.where(based_on_id: calendar_events.map(&:id)).destroy_all
    calendar_events.each do |calendar_event|
      child_event = calendar_event.dup
      child_event.based_on = calendar_event
      child_calendar.calendar_events << child_event
    end
  end

  private

  # brutal
  # should probably only be future events, or recent events, or events recently modified..
  def calendar_events_to_sync(calendar)
    calendar.calendar_events
  end
end
