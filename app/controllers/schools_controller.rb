class SchoolsController < ApplicationController
  include SchoolAggregation
  include AnalysisPages
  include DashboardEnergyCharts
  include DashboardAlerts
  include DashboardTimeline
  include DashboardPriorities
  include NonPublicSchools
  include SchoolProgress
  include Promptable

  load_and_authorize_resource except: [:show, :index]
  load_resource only: [:show]

  skip_before_action :authenticate_user!, only: [:index, :show, :usage]
  before_action :set_key_stages, only: [:new, :create, :edit, :update]

  before_action :check_aggregated_school_in_cache, only: [:show]

  #If this isn't a publicly visible school, then redirect away if user can't
  #view this school
  before_action only: [:show] do
    redirect_unless_permitted :show
  end

  #Redirect users associated with this school to a holding page, if its not
  #visible yet.
  #Admins will be sent to removal page
  #Other users will end up getting an access denied error
  before_action :redirect_if_not_visible, only: [:show]

  #Redirect pupil accounts associated with this school to the pupil dashboard
  #(unless they should see the adult dashboard)
  before_action :redirect_pupils, only: [:show]

  #Redirect guest / not logged in users to the pupil dashboard if not
  #data enabled to offer a better initial user experience
  before_action :redirect_to_pupil_dash_if_not_data_enabled, only: [:show]

  before_action :set_breadcrumbs

  def index
    @schools = School.visible.by_name
    @school_groups = SchoolGroup.by_name.select(&:has_visible_schools?)
    @ungrouped_visible_schools = School.visible.without_group.by_name
    @schools_not_visible = School.not_visible.by_name
  end

  def show
    #The before_actions will redirect users away in certain scenarios
    #If we reach this action, then the current user will be:
    #Not logged in, a guest, an admin, or any other user not directly linked to this school
    #OR an adult user for this school, or a pupil that is trying to view the adult dashboard
    authorize! :show, @school
    @show_data_enabled_features = show_data_enabled_features?
    setup_default_features
    setup_data_enabled_features if @show_data_enabled_features

    if params[:report] && @show_data_enabled_features
      render template: "management/schools/report", layout: 'report'
    else
      render :show
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

  def set_breadcrumbs
    if action_name.to_sym == :edit
      @breadcrumbs = [{ name: I18n.t('manage_school_menu.edit_school_details') }]
    else
      @breadcrumbs = [{ name: I18n.t('dashboards.adult_dashboard') }]
    end
  end

  def user_signed_in_and_linked_to_school?
    user_signed_in? && (current_user.school_id == @school.id)
  end

  def not_signed_in?
    !user_signed_in? || current_user.guest?
  end

  def redirect_if_not_visible
    redirect_to school_inactive_path(@school) if user_signed_in_and_linked_to_school? && !@school.visible?
    redirect_to removal_admin_school_path(@school) if !@school.active && can?(:remove_school, @school)
  end

  def redirect_pupils
    redirect_to pupils_school_path(@school) if user_signed_in_and_linked_to_school? && current_user.pupil? && !switch_dashboard?
  end

  def switch_dashboard?
    params[:switch].present? && params[:switch] == "true"
  end

  def redirect_to_pupil_dash_if_not_data_enabled
    redirect_to pupils_school_path(@school) if not_signed_in? && !@school.data_enabled
  end

  def setup_default_features
    @observations = setup_timeline(@school.observations)

    #Setup management dashboard features if users has permission
    #to do that
    @show_standard_prompts = show_standard_prompts?(@school)
    if can?(:show_management_dash, @school)
      @add_contacts = site_settings.message_for_no_contacts && @school.contacts.empty? && can?(:manage, Contact)
      @add_pupils = site_settings.message_for_no_pupil_accounts && @school.users.pupil.empty? && can?(:manage_users, @school)
      @prompt_training = @show_data_enabled_features && current_user.confirmed_at > 30.days.ago
      @prompt_for_bill = @school.bill_requested && can?(:index, ConsentDocument)
      @programmes_to_prompt = @school.programmes.last_started
    end
  end

  def setup_data_enabled_features
    @dashboard_alerts = setup_alerts(@school.latest_dashboard_alerts.management_dashboard, :management_dashboard_title)
    @management_priorities = setup_priorities(@school.latest_management_priorities, limit: site_settings.management_priorities_dashboard_limit)
    @overview_charts = setup_energy_overview_charts(@school.configuration)
    @overview_data = Schools::ManagementTableService.new(@school).management_data
    @progress_summary = progress_service.progress_summary
    @co2_pages = setup_co2_pages(@school.latest_analysis_pages)

    #Setup management dashboard features if users has permission
    #to do that
    if can?(:show_management_dash, @school)
      @add_targets = prompt_for_target?
      @set_new_target = prompt_to_set_new_target?
      @review_targets = prompt_to_review_target?
      @recent_audit = Audits::AuditService.new(@school).recent_audit
      @suggest_estimates_for_fuel_types = suggest_estimates_for_fuel_types(check_data: true)
    end
  end

  def set_key_stages
    @key_stages = KeyStage.order(:name)
  end

  def school_params
    params.require(:school).permit(
      :name,
      :activation_date,
      :school_type,
      :funding_status,
      :address,
      :postcode,
      :country,
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
      :alternative_heating_oil,
      :alternative_heating_lpg,
      :alternative_heating_biomass,
      :alternative_heating_district_heating,
      :enable_targets_feature,
      :public,
      :chart_preference,
      :funder_id,
      key_stage_ids: []
    )
  end
end
