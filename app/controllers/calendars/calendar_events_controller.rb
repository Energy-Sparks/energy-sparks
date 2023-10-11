class Calendars::CalendarEventsController < ApplicationController
  load_and_authorize_resource :calendar
  load_and_authorize_resource through: :calendar

  include Wisper::Publisher

  # GET /calendars
  def index
    academic_year_ids = @calendar.calendar_events.pluck(:academic_year_id).uniq.sort_by(&:to_i).reject(&:nil?)
    @academic_years = AcademicYear.find(academic_year_ids)
    @calendar_events = @calendar_events.order(:start_date)
  end

  def new
    @calendar_event = CalendarEvent.new
  end

  def edit; end

  # POST /calendars
  def create
    if @calendar_event.save
      broadcast(:calendar_edited, @calendar)
      respond_to do |format|
        format.html { redirect_to calendar_path(@calendar, anchor: "calendar_event_#{@calendar_event.id}"), notice: 'Calendar Event was successfully created.' }
        format.js { render :reload }
      end
    else
      render :new
    end
  end

  def update
    if HolidayFactory.new(@calendar).with_neighbour_updates(@calendar_event, calendar_event_params)
      broadcast(:calendar_edited, @calendar)
      respond_to do |format|
        format.html { redirect_to calendar_path(@calendar, anchor: "calendar_event_#{@calendar_event.id}"), notice: 'Event was successfully updated.' }
        format.js { render :reload }
      end
    else
      render :edit
    end
  end

  def destroy
    @calendar_event.destroy
    broadcast(:calendar_edited, @calendar)
    respond_to do |format|
      format.html { redirect_to calendar_path(@calendar), notice: 'Event was successfully deleted.' }
      format.js { render :reload }
    end
  end

  private

  def calendar_event_params
    params.require(:calendar_event).permit(:calendar_event_type_id, :start_date, :end_date, :school_id)
  end
end
