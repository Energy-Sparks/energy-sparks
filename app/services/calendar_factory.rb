class CalendarFactory
  def initialize(existing_calendar, group = existing_calendar.group, template = false)
    @existing_calendar = existing_calendar
    @group = group
    @template = template
  end

  def build
    new_calendar = @existing_calendar.dup
    new_calendar.group = @group
    new_calendar.template = @template

    @existing_calendar.calendar_events.each do |calendar_event|
      new_calendar_event = calendar_event.dup
      new_calendar.calendar_events << new_calendar_event
    end
    new_calendar
  end
end
