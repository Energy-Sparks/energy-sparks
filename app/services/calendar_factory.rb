class CalendarFactory
  def initialize(existing_calendar, area = existing_calendar.area, template = false)
    @existing_calendar = existing_calendar
    @area = area
    @template = template
  end

  def build
    @new_calendar = @existing_calendar.dup
    @new_calendar.area = @area
    @new_calendar.template = @template

    @academic_years = get_academic_years
    first_academic_year = @academic_years.order(:start_date).first
    create_padding_events(first_academic_year)

    @existing_calendar.calendar_events.each do |calendar_event|
      new_calendar_event = calendar_event.dup
      @new_calendar.calendar_events << new_calendar_event
    end

    last_academic_year = @academic_years.order(:start_date).last
    create_padding_events(last_academic_year)

    @new_calendar
  end

  def get_academic_years
    @first_template_term = @existing_calendar.first_event_date
    @last_template_term =  @existing_calendar.last_event_date
    AcademicYear.where('start_date <= ? and end_date >= ?', @last_template_term + 1.year, @first_template_term - 1.year)
  end

  def create_padding_events(academic_year)
    CalendarEventType.where(term_time: true).each do |cet|
      @new_calendar.calendar_events << CalendarEvent.new(
        calendar_event_type: cet,
        title: cet.title,
        academic_year: academic_year,
        start_date: academic_year.start_date,
        end_date: academic_year.end_date)
    end
  end
end
