class Schools::CalendarsController < CalendarsController
  before_action :set_school

  def show
    @template = @school.calendar.template?
  end

  def new
    calendar_factory = CalendarFactory.new(@school.calendar)
    @academic_years = calendar_factory.get_academic_years
    @calendar = calendar_factory.build
  end

  # POST /calendars
  # POST /calendars.json
  def create
    @calendar = Calendar.new(calendar_params)

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
    [:id, :title, :start_date, :end_date, :calendar_event_type_id, :academic_year_id]
  end

  def set_school
    @school = School.find(params[:school_id])
  end
end
