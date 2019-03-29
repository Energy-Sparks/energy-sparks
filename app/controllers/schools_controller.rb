class SchoolsController < ApplicationController
  include ActivityTypeFilterable
  include Measurements

  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:index, :show, :usage, :awards]
  before_action :set_key_stages, only: [:new, :create, :edit, :update]

  # GET /schools
  # GET /schools.json
  def index
    @scoreboards = Scoreboard.includes(:schools).where.not(schools: { id: nil }).order(:name)
    @ungrouped_active_schools = School.active.without_group.order(:name)
    @schools_not_active = School.inactive.order(:name)
  end

  # GET /schools/1
  # GET /schools/1.json
  def show
    redirect_to teachers_school_path(@school), status: :found
  end

  # GET /schools/:id/awards
  def awards
    @all_badges = Merit::Badge.all.to_a.sort
    @badges = @school.badges_by_date(order: :asc)
  end

  def suggest_activity
    @filter = activity_type_filter
    @first = @school.activities.empty?
    @suggestions = NextActivitySuggesterWithFilter.new(@school, @filter).suggest
  end

  # GET /schools/new
  def new
  end

  # GET /schools/1/edit
  def edit
  end

  # POST /schools
  # POST /schools.json
  def create
    respond_to do |format|
      if @school.save
        SchoolCreator.new(@school).process_new_school!
        format.html { redirect_to new_school_school_group_path(@school), notice: 'School was successfully created.' }
        format.json { render :show, status: :created, location: @school }
      else
        format.html { render :new }
        format.json { render json: @school.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /schools/1
  # PATCH/PUT /schools/1.json
  def update
    respond_to do |format|
      if @school.update(school_params)
        AggregateSchoolService.new(@school).invalidate_cache
        format.html { redirect_to @school, notice: 'School was successfully updated.' }
        format.json { render :show, status: :ok, location: @school }
      else
        format.html { render :edit }
        format.json { render json: @school.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /schools/1
  # DELETE /schools/1.json
  def destroy
    @school.destroy
    respond_to do |format|
      format.html { redirect_to schools_url, notice: 'School was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /schools/:id/usage
  def usage
    set_measurement_options
    @measurement = measurement_unit(params[:measurement])

    set_supply
    if @supply
      set_first_date
      set_to_date
      render "#{period}_usage"
    else
      redirect_to school_path(@school), notice: 'No suitable supply could be found'
    end
  end

private

  def set_key_stages
    @key_stages = KeyStage.order(:name)
  end

  def school_params
    params.require(:school).permit(
      :name,
      :school_type,
      :address,
      :postcode,
      :website,
      :urn,
      :number_of_pupils,
      :floor_area,
      key_stage_ids: []
    )
  end

  def set_supply
    @supply = params[:supply].present? ? params[:supply] : supply_from_school
  end

  def supply_from_school
    case @school.fuel_types
    when :electric_and_gas, :electric_only then 'electricity'
    when :gas_only then 'gas'
    end
  end

  def period
    params[:period].present? ? params[:period] : "hourly"
  end

  def set_first_date
    if period == "hourly"
      begin
        @first_date = Date.parse params[:first_date]
      rescue
        @first_date = @school.last_reading_date(@supply)
      end
    else
      begin
        @first_date = Date.parse params[:first_date]
      rescue
        @first_date = @school.last_reading_date(@supply)
      end
      #ensure we're looking at beginning of the week
      @first_date = @first_date.beginning_of_week(:sunday) if @first_date.present?
    end
  end

  def set_to_date
    if period == "hourly"
      begin
        @to_date = Date.parse params[:to_date]
      rescue
        @to_date = nil
      end
    else
      begin
        @to_date = Date.parse params[:to_date]
      rescue
        last_reading = @school.last_reading_date(@supply)
        @to_date = last_reading - 7.days if last_reading.present?
      end
      #ensure we're looking at beginning of the week
      @to_date = @to_date.beginning_of_week(:sunday) if @to_date.present?
    end
  end
end
