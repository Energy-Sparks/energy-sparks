class CalendarResyncService
  def initialize(calendar, from_date = nil)
    @calendar = calendar
    @from_date = from_date || @calendar.created_at
  end

  def resync
    parent_events = @calendar.calendar_events
    parent_events_to_sync = calendar_events_to_sync(@calendar, @from_date)
    @calendar.calendars.each do |child_calendar|
      child_calendar.transaction do
        deleted_events = delete_orphaned_child_events(child_calendar, parent_events)
        created_events = resync_child_events(child_calendar, parent_events_to_sync)
        # will only apply when resyncing from national calendar
        child_calendar.calendars.each do |grandchild_calendar|
          grandchild_calendar.calendar_events.where(based_on_id: deleted_events.map(&:id)).destroy_all
          resync_child_events(grandchild_calendar, created_events)
        end
      end
    end
  end

  private

  def calendar_events_to_sync(calendar, from_date)
    calendar.calendar_events.where('updated_at >= ?', from_date)
  end

  def delete_orphaned_child_events(child_calendar, parent_events)
    child_calendar.calendar_events.where.not(based_on_id: nil).where.not(based_on_id: parent_events.map(&:id)).destroy_all
  end

  def resync_child_events(child_calendar, calendar_events)
    child_calendar.calendar_events.where(based_on_id: calendar_events.map(&:id)).destroy_all
    created_events = calendar_events.map do |calendar_event|
      calendar_event.dup.tap do |new_event|
        new_event.based_on = calendar_event
      end
    end
    child_calendar.calendar_events << created_events
    raise StandardError.new(error_message(child_calendar)) if child_calendar.invalid?
    created_events
  rescue => e
    puts e.inspect
    []
  end

  def error_message(calendar)
    calendar.calendar_events.select(&:invalid?).map do |ce|
      ce.display_title + ": " + ce.errors.full_messages.join(',')
    end
  end
end
