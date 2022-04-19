class CalendarResetService
  def initialize(calendar)
    @calendar = calendar
  end

  def reset
    CalendarEvent.transaction do
      @calendar.calendar_events.destroy_all
      if @calendar.based_on
        @calendar.based_on.calendar_events.each do |calendar_event|
          @calendar.calendar_events << calendar_event.dup
        end
      end
    end
  end
end
