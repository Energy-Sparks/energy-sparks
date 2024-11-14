class SchoolsController < ApplicationController
  include SchoolAggregation
  include NonPublicSchools
  include Promptable
  include DashboardTimeline
  include SchoolProgress

  load_and_authorize_resource except: [:show, :index]
  load_resource only: [:show]

  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_key_stages, only: [:create, :edit, :update]
  before_action :set_search_scope, only: [:index]

  protect_from_forgery except: :index

  # If this isn't a publicly visible school, then redirect away if user can't
  # view this school
  before_action only: [:show] do
    redirect_unless_permitted :show
  end

  # Redirect users associated with this school to a holding page, if its not
  # visible yet.
  # Admins will be sent to removal page
  # Other users will end up getting an access denied error
  before_action :redirect_if_not_visible, only: [:show]

  # Redirect pupil accounts associated with this school to the pupil dashboard
  # (unless they should see the adult dashboard)
  before_action :redirect_pupils, only: [:show]

  # Redirect guest / not logged in users to the pupil dashboard if not
  # data enabled to offer a better initial user experience
  before_action :redirect_to_pupil_dash_if_not_data_enabled, only: [:show]

  before_action :set_breadcrumbs

  def index
    if Flipper.enabled?(:new_schools_page, current_user)
      @letter = search_params.fetch(:letter, nil)
      @keyword = search_params.fetch(:keyword, nil)
      if @keyword
        @results = @scope.by_keyword(@keyword).by_name
      else
        @results = @scope.by_letter(@letter).by_name
      end
      @count = @results.count
    else
      @schools = School.visible.by_name.select(:name, :slug)
      @school_groups = SchoolGroup.by_name.select(&:has_visible_schools?)
      @ungrouped_visible_schools = School.visible.without_group.by_name.select(:name, :slug)
      @schools_not_visible = School.not_visible.by_name.select(:name, :slug)
    end
  end

  def show
    # The before_actions will redirect users away in certain scenarios
    # If we reach this action, then the current user will be:
    # Not logged in, a guest, an admin, or any other user not directly linked to this school
    # OR an adult user for this school, or a pupil that is trying to view the adult dashboard
    authorize! :show, @school
    @audience = :adult
    @observations = setup_timeline(@school.observations)
    @progress_summary = progress_service.progress_summary if @school.data_enabled?
    render :show, layout: 'dashboards'
  end

  # GET /schools/1/edit
  def edit
  end

  # POST /schools
  # POST /schools.json
  def create
    respond_to do |format|
      # ensure schools are created as not visible initially
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

  def set_search_scope
    @tab = SchoolSearchComponent.sanitize_tab(search_params.fetch(:scope).to_sym)
    @scope = if @tab == :schools
               current_user_admin? ? School.active : School.visible
             else
               SchoolGroup.all
             end
  end

  def search_params
    params.permit(:letter, :keyword, :scope).with_defaults(letter: 'A', scope: SchoolSearchComponent::DEFAULT_TAB)
  end

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
    params[:switch].present? && params[:switch] == 'true'
  end

  def redirect_to_pupil_dash_if_not_data_enabled
    redirect_to pupils_school_path(@school) if not_signed_in? && !@school.data_enabled
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
      :alternative_heating_ground_source_heat_pump,
      :alternative_heating_air_source_heat_pump,
      :alternative_heating_water_source_heat_pump,
      :enable_targets_feature,
      :public,
      :chart_preference,
      :funder_id,
      key_stage_ids: []
    )
  end
end
