class CalendarsController < ApplicationController
  load_and_authorize_resource
  skip_before_action :authenticate_user!
  before_action :set_calendar, only: [:show, :edit, :update, :destroy]

  # GET /calendars
  # GET /calendars.json
  def index
    @calendars = Calendar.all.order(created_at: :desc)
  end

  # GET /calendars/1
  # GET /calendars/1.json
  def show
    # TODO Hard coding
    @calendar = Calendar.last
  end

  # GET /calendars/new
  def new
    @calendar = Calendar.new
    build_terms
  end

  # GET /calendars/1/edit
  def edit
    build_terms
  end

  # POST /calendars
  # POST /calendars.json
  def create
    @calendar = Calendar.new(calendar_params)

    respond_to do |format|
      if @calendar.save
        format.html { redirect_to @calendar, notice: 'Calendar was successfully created.' }
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
      if @calendar.update(calendar_params)
        format.html { redirect_to @calendar, notice: 'Calendar was successfully updated.' }
        format.json { render :show, status: :ok, location: @calendar }
      else
        format.html { render :edit }
        format.json { render json: @calendar.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /calendars/1
  # DELETE /calendars/1.json
  def destroy
    @calendar.update_attribute(:deleted, true)
    respond_to do |format|
      format.html { redirect_to calendars_url, notice: 'Calendar was marked as deleted.' }
      format.json { head :no_content }
    end
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_calendar
    @calendar = Calendar.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def calendar_params
    params.require(:calendar).permit(:name, terms_attributes: term_params)
  end

  def term_params
    [:id, :academic_year, :name, :start_date, :end_date, :_destroy]
  end

  def build_terms
    number_to_build = 6 - @calendar.terms.count
    number_to_build = 1 if number_to_build < 1
    number_to_build.times do
      @calendar.terms.build
    end
  end
end
