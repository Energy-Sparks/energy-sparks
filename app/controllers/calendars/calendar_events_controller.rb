class Calendars::CalendarEventsController < ApplicationController
  load_and_authorize_resource
  skip_before_action :authenticate_user!
  before_action :set_calendar
  before_action set_calendar_event: [:edit, :destroy]

  # GET /calendars
  # GET /calendars.json
  def index
    academic_year_ids = @calendar.calendar_events.pluck(:academic_year_id).uniq.sort_by(&:to_i).reject(&:nil?)
    @academic_years = AcademicYear.find(academic_year_ids)
    @calendar_events = @calendar.calendar_events.order(:start_date)
  end

  def new
  end

  def edit
  end

  # POST /calendars
  # POST /calendars.json
  def create
    @calendar_event = CalendarEvent.new(calendar_event_params)
    @calendar_event.calendar = @calendar
    respond_to do |format|
      if @calendar_event.save
        format.html { redirect_to @calendar, notice: 'Calendar Event was successfully created.' }
        format.json { render :show, status: :created, location: @calendar }
      else
        format.html { render :new }
        format.json { render json: @calendar.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @calendar_event.update(calendar_event_params)
        format.html { redirect_to calendar_path(@calendar), notice: 'Event was successfully updated.' }
        format.json { render :show, status: :created, location: @calendar }
      else
        format.html { render :new }
        format.json { render json: @calendar.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @calendar_event.destroy
    respond_to do |format|
      format.html { redirect_to calendar_calendar_events_path(@calendar), notice: 'Event was successfully deleted.' }
      format.json { head :no_content }
    end
  end

private

  def set_calendar_event
    @calendar_event = CalendarEvent.find(params[:id])
  end

  def set_calendar
    @calendar = Calendar.find(params[:calendar_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def calendar_event_params
    params.require(:calendar_event).permit(:title, :academic_year_id, :calendar_event_type_id, :start_date, :end_date, :school_id)
  end
end
