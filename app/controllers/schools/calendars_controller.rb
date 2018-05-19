class Schools::CalendarsController < CalendarsController
  before_action :set_school

  def show
    @template = @school.calendar.template?
  end

  def new
    @first_template_term = @school.calendar.calendar_events.first.start_date
    @last_template_term = @school.calendar.calendar_events.last.end_date
    @academic_years = AcademicYear.where('start_date <= ? and end_date >= ?', @last_template_term + 1.year, @first_template_term - 1.year)
    @calendar = CalendarFactory.new(@school.calendar).build
  end

private

  def set_school
    @school = School.find(params[:school_id])
  end
end
