class Calendars::CalendarEventsController < ApplicationController
  load_and_authorize_resource :calendar
  load_and_authorize_resource through: :calendar

  # GET /calendars
  # GET /calendars.json
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
  # POST /calendars.json
  def create
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
      if HolidayFactory.new(@calendar).with_neighbour_updates(@calendar_event, calendar_event_params)
        format.html { redirect_to calendar_path(@calendar), notice: 'Event was successfully updated.' }
        format.json { render :show, status: :updated, location: @calendar_event }
      else
        format.html { render :edit }
        format.json { render json: @calendar_event.errors, status: :unprocessable_entity }
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

  def calendar_event_params
    params.require(:calendar_event).permit(:title, :academic_year_id, :calendar_event_type_id, :start_date, :end_date, :school_id)
  end
end
