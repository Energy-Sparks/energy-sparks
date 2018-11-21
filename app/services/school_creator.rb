class SchoolCreator
  def initialize(school)
    @school = school
  end

  def process_new_school!
    add_school_times
  end

  def add_school_times
    SchoolTime.days.each do |day, _value|
      @school.school_times.create(day: day)
    end
  end

  def process_configuration!
    generate_calendar
  end

private

  def generate_calendar
    if (area = @school.calendar_area)
      if (template = area.calendars.find_by(template: true))
        calendar = CalendarFactory.new(template, @school.name).create
        @school.update!(calendar: calendar)
      end
    end
  end
end
