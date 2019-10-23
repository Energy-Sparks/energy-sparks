class Calendars::CalendarEventsController < ApplicationController
  load_and_authorize_resource :calendar
  load_and_authorize_resource through: :calendar

  # GET /calendars
  def index
    academic_year_ids = @calendar.calendar_events.pluck(:academic_year_id).uniq.sort_by(&:to_i).reject(&:nil?)
    @academic_years = AcademicYear.find(academic_year_ids)
    @calendar_events = @calendar_events.order(:start_date)
  end

  def new
    @calendar_event = CalendarEvent.new
  end

  def edit
  end

  # POST /calendars
  def create
    if @calendar_event.save
      redirect_to @calendar, notice: 'Calendar Event was successfully created.'
    else
      render :new
    end
  end

  def update
    if HolidayFactory.new(@calendar).with_neighbour_updates(@calendar_event, calendar_event_params)
      redirect_to calendar_path(@calendar), notice: 'Event was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @calendar_event.destroy
    redirect_to calendar_path(@calendar), notice: 'Event was successfully deleted.'
  end

private

  def calendar_event_params
    params.require(:calendar_event).permit(:title, :calendar_event_type_id, :start_date, :end_date, :school_id)
  end
end
