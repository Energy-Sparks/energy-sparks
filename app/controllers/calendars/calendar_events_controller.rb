class Calendars::CalendarEventsController < ApplicationController
  load_and_authorize_resource
  skip_before_action :authenticate_user!
  before_action :set_calendar

  # GET /calendars
  # GET /calendars.json
  def index
    @template_calendars = Calendar.template
    @customised_calendars = Calendar.custom
 #   @calendars = Calendar.all.order(created_at: :desc)
  end

  # GET /calendars/1
  # GET /calendars/1.json
  def show
  end

  # GET /calendars/new
  def new
    # @calendar = Calendar.new
    # build_terms
  end

  # GET /calendars/1/edit
  def edit
    # if @calendar.template?
    #   redirect_to calendar_path(@calendar)
    # end
    # build_terms
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

  # PATCH/PUT /calendars/1
  # PATCH/PUT /calendars/1.json
  def update
    respond_to do |format|
      if @calendar_event.update(calendar_event_params)
        format.html { redirect_to calendar_path(@calendar), notice: 'Calendar Event was successfully created.' }
        format.json { render :show, status: :created, location: @calendar }
      else
        format.html { render :new }
        format.json { render json: @calendar.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /calendars/1
  # DELETE /calendars/1.json
  def destroy
    # @calendar.update_attribute(:deleted, true)
    # respond_to do |format|
    #   format.html { redirect_to calendars_url, notice: 'Calendar was marked as deleted.' }
    #   format.json { head :no_content }
    # end
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_calendar
    @calendar = Calendar.find(params[:calendar_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def calendar_event_params
    params.require(:calendar_event).permit(:title, :academic_year_id, :calendar_event_type_id, :start_date, :end_date, :school_id)
  end
end
