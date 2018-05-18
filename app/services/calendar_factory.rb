class CalendarFactory
  def initialize(existing_calendar, area = existing_calendar.area, template = false)
    @existing_calendar = existing_calendar
    @area = area
    @template = template
  end

  def build
    new_calendar = @existing_calendar.dup
    new_calendar.area = @area
    new_calendar.template = @template

    @existing_calendar.calendar_events.each do |calendar_event|
      new_calendar_event = calendar_event.dup
      new_calendar.calendar_events << new_calendar_event
    end
    new_calendar
  end
end
