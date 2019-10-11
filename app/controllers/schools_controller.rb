class SchoolsController < ApplicationController
  include SchoolAggregation
  include ActivityTypeFilterable
  include Measurements
  include DashboardEnergyCharts
  include DashboardAlerts
  include DashboardTimeline

  load_and_authorize_resource
  skip_before_action :authenticate_user!, only: [:index, :show, :usage]
  before_action :set_key_stages, only: [:new, :create, :edit, :update]

  before_action :check_aggregated_school_in_cache, only: [:show]

  # GET /schools
  def index
    @scoreboards = Scoreboard.includes(schools: :configuration).where.not(schools: { id: nil }).order(:name)
    @ungrouped_active_schools = School.active.without_group.order(:name)
    @schools_not_active = School.inactive.order(:name)
  end

  # GET /schools/1
  def show
    if current_user && (current_user.school_id == @school.id || current_user.admin?)
      redirect_to_dashboard
    else
      @charts = setup_charts(@school.configuration)
      @dashboard_alerts = setup_alerts(@school.latest_dashboard_alerts.public_dashboard, :public_dashboard_title)
      @observations = setup_timeline(@school.observations)
    end
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
      :has_solar_panels,
      :has_swimming_pool,
      :serves_dinners,
      :cooks_dinners_onsite,
      :cooks_dinners_for_other_schools,
      :cooks_dinners_for_other_schools_count,
      key_stage_ids: []
    )
  end

  def redirect_to_dashboard
    if @school.active? || current_user.admin?
      if current_user.pupil?
        redirect_to pupils_school_path(@school), status: :found
      elsif current_user.staff_role
        redirect_to [current_user.staff_role.dashboard.to_sym, @school], status: :found
      else
        redirect_to management_school_path(@school), status: :found
      end
    else
      redirect_to school_inactive_path(@school)
    end
  end
end
