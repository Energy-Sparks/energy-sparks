class CalendarEventListener
  def calendar_edited(calendar)
    ScheduleDataManagerService.invalidate_cached_calendar(calendar)
  end
end
