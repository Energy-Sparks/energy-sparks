class CalendarFactory
  def initialize(existing_calendar:, title: existing_calendar.title, calendar_type: :school)
    @existing_calendar = existing_calendar
    @title = title
    @calendar_type = calendar_type
  end

  def build
    @new_calendar = @existing_calendar.dup
    @new_calendar.title = @title
    @new_calendar.calendar_type = @calendar_type
    @new_calendar.based_on = @existing_calendar

    @existing_calendar.calendar_events.each do |calendar_event|
      new_calendar_event = calendar_event.dup
      new_calendar_event.based_on = calendar_event
      new_calendar_event.calendar_id = @new_calendar.id

      new_calendar_event.save!

      @new_calendar.calendar_events << new_calendar_event
    end

    @new_calendar
  end

  def create
    build.save!
    @new_calendar
  end
end
