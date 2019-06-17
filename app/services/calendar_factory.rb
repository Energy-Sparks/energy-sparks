class CalendarFactory
  def initialize(existing_calendar, title = existing_calendar.title, area = existing_calendar.calendar_area, template = false)
    @existing_calendar = existing_calendar
    @title = title
    @area = area
    @template = template
  end

  def build
    @new_calendar = @existing_calendar.dup
    @new_calendar.calendar_area = @area
    @new_calendar.title = @title
    @new_calendar.template = @template
    @new_calendar.based_on = @existing_calendar

    @existing_calendar.calendar_events.each do |calendar_event|
      new_calendar_event = calendar_event.dup
      @new_calendar.calendar_events << new_calendar_event
    end

    @new_calendar
  end

  def create
    build.save!
    @new_calendar
  end
end
