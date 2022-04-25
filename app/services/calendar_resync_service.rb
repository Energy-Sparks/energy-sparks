class CalendarResyncService
  def initialize(calendar)
    @calendar = calendar
  end

  def resync
    calendar_events = calendar_events_to_sync(@calendar)
    Calendar.transaction do
      calendar_events.each do |calendar_event|
        resync_child_events(calendar_event)
      end
    end
  end

  def resync_child_events(calendar_event)
    attrs = calendar_event.attributes.slice('academic_year_id', 'calendar_event_type_id', 'description', 'start_date', 'end_date')
    calendar_event.calendar_events.each do |child_event|
      child_event.update(attrs)
    end
  end

  private

  # brutal
  # should probably only be future events, or recent events, or events recently modified..
  def calendar_events_to_sync(calendar)
    calendar.calendar_events
  end

  def check_whether_child_needs_creating(parent_calendar_event, child_calendar)
    unless there_is_an_overlapping_child_event?(parent_calendar_event, child_calendar)
      duplicate = parent_calendar_event.dup
      duplicate.calendar = child_calendar
      duplicate.based_on = parent_calendar_event
      duplicate.save!
    end
  end

  def there_is_an_overlapping_child_event?(calendar_event, child_calendar)
    overlap_types = if calendar_event.calendar_event_type.term_time || calendar_event.calendar_event_type.holiday
                      (CalendarEventType.holiday + CalendarEventType.term)
                    else
                      [calendar_event.calendar_event_type]
                    end
    new_start_date = calendar_event.start_date
    new_end_date = calendar_event.end_date
    any_overlapping_before = any_overlapping_here?(overlap_types, child_calendar, new_start_date)
    any_overlapping_after = any_overlapping_here?(overlap_types, child_calendar, new_end_date)
    any_overlapping_before || any_overlapping_after
  end

  def any_overlapping_here?(overlap_types, child_calendar, date_to_check)
    child_calendar.calendar_events.where(calendar_event_type: overlap_types).where('start_date <= ? and end_date >= ?', date_to_check, date_to_check).any?
  end
end
