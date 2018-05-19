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

  # POST /calendars
  # POST /calendars.json
  def create
    @calendar = Calendar.new(calendar_params)

    # oijoij
    respond_to do |format|
      if @calendar.save
        @school.update(calendar: @calendar)
        format.html { redirect_to [@school, @calendar], notice: 'Calendar was successfully created.' }
        format.json { render :show, status: :created, location: @calendar }
      else
        format.html { render :new }
        format.json { render json: @calendar.errors, status: :unprocessable_entity }
      end
    end
  end

private

  # Never trust parameters from the scary internet, only allow the white list through.
  def calendar_params
    params.require(:calendar).permit(:title, calendar_events_attributes: calendar_event_params)
  end

  def calendar_event_params
    [:id, :title, :start_date, :end_date, :calendar_event_type_id]
  end

  def set_school
    @school = School.find(params[:school_id])
  end
end
