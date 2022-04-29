class CalendarResyncService
  def initialize(calendar, from_date = nil)
    @calendar = calendar
    @from_date = from_date || @calendar.created_at
  end

  def resync
    parent_event_ids = @calendar.calendar_events.map(&:id)
    sync_events = calendar_events_to_sync(@calendar, @from_date)
    @calendar.calendars.each do |child_calendar|
      child_calendar.transaction do
        delete_orphaned_child_events(child_calendar, parent_event_ids)
        resync_child_events(child_calendar, sync_events)
      end
    end
  end

  private

  def calendar_events_to_sync(calendar, from_date)
    calendar.calendar_events.where('updated_at > ?', from_date)
  end

  def delete_orphaned_child_events(child_calendar, parent_event_ids)
    child_calendar.calendar_events.where.not(based_on_id: nil).where.not(based_on_id: parent_event_ids).destroy_all
  end

  def resync_child_events(child_calendar, calendar_events)
    child_calendar.calendar_events.where(based_on_id: calendar_events.map(&:id)).destroy_all
    calendar_events.each do |calendar_event|
      child_event = calendar_event.dup
      child_event.based_on = calendar_event
      child_calendar.calendar_events << child_event
    end
  end
end
