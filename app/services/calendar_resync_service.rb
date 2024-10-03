class CalendarResyncService
  attr_reader :successes, :failures, :calendar

  def initialize(calendar, from_date = nil)
    @calendar = calendar
    @from_date = from_date || @calendar.created_at
    @successes = []
    @failures = []
  end

  def resync
    parent_events = @calendar.calendar_events
    parent_events_to_sync = calendar_events_to_sync(@calendar, @from_date)

    @calendar.calendars.each do |child_calendar|
      begin
        child_calendar.transaction do
          calendar_successes = []

          deleted_events = delete_orphaned_child_events(child_calendar, parent_events)
          created_events = resync_child_events(child_calendar, parent_events_to_sync)
          calendar_successes << success_details(child_calendar, deleted_events, created_events)

          # will only apply when resyncing from national calendar
          child_calendar.calendars.each do |grandchild_calendar|
            grandchild_deleted_events = grandchild_calendar.calendar_events.where(based_on_id: deleted_events.map(&:id)).destroy_all
            grandchild_created_events = resync_child_events(grandchild_calendar, created_events)
            calendar_successes << success_details(grandchild_calendar, grandchild_deleted_events, grandchild_created_events)
          end

          @successes.concat(calendar_successes)
        end
      rescue => e
        @failures << failure_details(child_calendar, e.message)
      end
    end
  end

  private

  def success_details(calendar, deleted_events, created_events)
    { calendar: calendar, deleted: deleted_events, created: created_events }
  end

  def failure_details(calendar, message)
    { calendar: calendar, message: message }
  end

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

    raise StandardError.new(error_message(created_events)) if created_events.any? { |event| !event.errors.empty? }

    created_events
  end

  def error_message(calendar_events)
    calendar_events.select { |event| !event.errors.empty? }.map do |ce|
      ce.display_title + ': ' + ce.errors.full_messages.join(',')
    end
  end
end
