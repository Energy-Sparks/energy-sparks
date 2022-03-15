class SchoolsController < ApplicationController
  include SchoolAggregation
  include ActivityTypeFilterable
  include AnalysisPages
  include DashboardEnergyCharts
  include DashboardAlerts
  include DashboardTimeline
  include DashboardPriorities
  include NonPublicSchools
  include SchoolProgress

  load_and_authorize_resource except: [:show, :index]
  load_resource only: [:show]

  skip_before_action :authenticate_user!, only: [:index, :show, :usage]
  before_action :set_key_stages, only: [:new, :create, :edit, :update]

  before_action :check_aggregated_school_in_cache, only: [:show]

  before_action only: [:show] do
    redirect_unless_permitted :show
  end

  # GET /schools
  def index
    @schools = School.visible.by_name
    @school_groups = SchoolGroup.by_name.select(&:has_visible_schools?)
    @ungrouped_visible_schools = School.visible.without_group.by_name
    @schools_not_visible = School.not_visible.by_name
  end

  # retain the original index page
  def list
    @school_groups = SchoolGroup.by_name
    @ungrouped_visible_schools = School.visible.without_group.by_name
    @schools_not_visible = School.not_visible.by_name
  end

  # GET /schools/1
  def show
    if go_to_specific_dashboard?
      redirect_to_specific_dashboard
    else
      redirect_to pupils_school_path(@school) unless @school.data_enabled
      authorize! :show, @school
      @show_data_enabled_features = show_data_enabled_features?
      setup_default_features
      setup_data_enabled_features if @show_data_enabled_features
    end
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
      #ensure schools are created as not visible initially
      @school.visible = false
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
        Schools::SchoolUpdater.new(@school).after_update!
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

  def setup_default_features
    @observations = setup_timeline(@school.observations)
  end

  def setup_data_enabled_features
    @dashboard_alerts = setup_alerts(@school.latest_dashboard_alerts.public_dashboard, :public_dashboard_title)
    @management_priorities = setup_priorities(@school.latest_management_priorities, limit: site_settings.management_priorities_dashboard_limit)
    @overview_charts = setup_energy_overview_charts(@school.configuration)
    if EnergySparks::FeatureFlags.active?(:use_management_data)
      @overview_data = Schools::ManagementTableService.new(@school).management_data
    else
      @overview_table = Schools::ManagementTableService.new(@school).management_table
    end
    @progress_summary = progress_service.progress_summary
    @co2_pages = setup_co2_pages(@school.latest_analysis_pages)
  end

  def go_to_specific_dashboard?
    current_user && (current_user.school_id == @school.id || can?(:manage, :admin_functions))
  end

  def set_key_stages
    @key_stages = KeyStage.order(:name)
  end

  def school_params
    params.require(:school).permit(
      :name,
      :activation_date,
      :school_type,
      :address,
      :postcode,
      :latitude,
      :longitude,
      :website,
      :urn,
      :number_of_pupils,
      :floor_area,
      :percentage_free_school_meals,
      :indicated_has_solar_panels,
      :indicated_has_storage_heaters,
      :has_swimming_pool,
      :serves_dinners,
      :cooks_dinners_onsite,
      :cooks_dinners_for_other_schools,
      :cooks_dinners_for_other_schools_count,
      :enable_targets_feature,
      :public,
      :chart_preference,
      key_stage_ids: []
    )
  end

  def redirect_to_specific_dashboard
    if @school.visible? || can?(:manage, :admin_functions)
      redirect_for_active_school_or_admin
    else
      redirect_to school_inactive_path(@school)
    end
  end

  def redirect_for_active_school_or_admin
    if current_user.pupil?
      redirect_to pupils_school_path(@school), status: :found
    else
      redirect_to management_school_path(@school), status: :found
    end
  end
end
