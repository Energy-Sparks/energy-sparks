class CalendarsController < ApplicationController
  load_and_authorize_resource

  # GET /calendars
  # GET /calendars.json
  def index
    @template_calendars = Calendar.template
    @customised_calendars = Calendar.custom.includes(:schools).order('schools.name')
  end

  # GET /calendars/1
  # GET /calendars/1.json
  def show
  end

  # GET /calendars/new
  def new
    build_terms
  end

  # GET /calendars/1/edit
  def edit
    if @calendar.template?
      redirect_to calendar_path(@calendar)
    end
    build_terms
  end

  # POST /calendars
  # POST /calendars.json
  def create
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
