class SchoolsController < ApplicationController
  include ActivityTypeFilterable
  include Measurements
  include DashboardEnergyCharts
  include DashboardAlerts
  include DashboardTimeline

  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:index, :show, :usage]
  before_action :set_key_stages, only: [:new, :create, :edit, :update]

  # GET /schools
  def index
    @scoreboards = Scoreboard.includes(:schools).where.not(schools: { id: nil }).order(:name)
    @ungrouped_active_schools = School.active.without_group.order(:name)
    @schools_not_active = School.inactive.order(:name)
  end

  # GET /schools/1
  def show
    setup_charts
    setup_dashboard_alerts
    setup_activity_suggestions
    setup_timeline
  end

  def suggest_activity
    @filter = activity_type_filter
    @first = @school.activities.empty?
    suggester = NextActivitySuggesterWithFilter.new(@school, activity_type_filter)
    @suggestions_from_programmes = suggester.suggest_from_programmes.limit(6)
    @suggestions_from_alerts = suggester.suggest_from_programmes.sample(6)
    @suggestions_from_activity_history = suggester.suggest_from_activity_history.first(6)
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

  def setup_activity_suggestions
    @activities_count = @school.activities.count
    suggester = NextActivitySuggesterWithFilter.new(@school, activity_type_filter)
    @activities_from_programmes = suggester.suggest_from_programmes.limit(1)
    @activities_from_alerts = suggester.suggest_from_find_out_mores.sample(1)
    if @activities_from_programmes.empty?
      started_programmes = @school.programmes.active
      @suggested_programme = ProgrammeType.active.where.not(id: started_programmes.map(&:programme_type_id)).sample
    end
    cards_filled = [@activities_from_programmes + @activities_from_alerts + [@suggested_programme]].flatten.compact.size
    @activities_from_activity_history = suggester.suggest_from_activity_history.slice(0, (3 - cards_filled))
  end

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
