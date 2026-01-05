class SchoolsController < ApplicationController
  include SchoolAggregation
  include NonPublicSchools
  include Promptable
  include DashboardTimeline
  include SchoolProgress

  layout 'dashboards', only: %i[show settings]

  load_and_authorize_resource except: %i[show index]
  load_resource only: [:show]
  before_action only: [:index] do
    redirect_to_school
  end

  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_key_stages, only: %i[create edit update]
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
    @letter = search_params.fetch(:letter, nil)
    @keyword = search_params.fetch(:keyword, nil)
    @results = if @keyword
                 @scope.by_keyword(@keyword).by_name
               else
                 @scope.by_letter(@letter, SchoolSearchComponent.ignore_prefix(@tab)).by_name
               end
    @count = @results.count
    @school_count = School.visible.count
  end

  def show
    # The before_actions will redirect users away in certain scenarios
    # If we reach this action, then the current user will be:
    # Not logged in, a guest, an admin, or any other user not directly linked to this school
    # OR an adult user for this school, or a pupil that is trying to view the adult dashboard
    authorize! :show, @school
    @audience = :adult
    @observations = setup_timeline(@school.observations.includes(:activity, :intervention_type))
    @progress_summary = progress_service.progress_summary if @school.data_enabled?
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

  def settings
    authorize! :manage_settings, @school
  end

  private

  def redirect_to_school
    if params[:school].present?
      redirect_to school_path(params[:school]) and return
    end
  end

  def set_search_scope
    @tab = SchoolSearchComponent.sanitize_tab(search_params.fetch(:scope).to_sym)
    @schools = current_user_admin? ? School.active : School.visible
    @scope = case @tab
             when :schools
               @schools
             when :diocese
               SchoolGroup.diocese_groups.with_visible_schools
             when :areas
               SchoolGroup.area_groups.with_visible_schools
             else
               SchoolGroup.organisation_groups.with_visible_schools
             end
  end

  def search_params
    params.permit(:letter, :keyword, :scope).with_defaults(letter: 'A', scope: SchoolSearchComponent::DEFAULT_TAB)
  end

  def set_breadcrumbs
    @breadcrumbs = if action_name.to_sym == :edit
                     [{ name: I18n.t('manage_school_menu.edit_school_details') }]
                   else
                     [{ name: I18n.t('dashboards.adult_dashboard') }]
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
    return unless user_signed_in_and_linked_to_school? && current_user.student_user? && !switch_dashboard?

    redirect_to pupils_school_path(@school)
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
    allowed = %i[
      name
      activation_date
      school_type
      funding_status
      address
      postcode
      country
      latitude
      longitude
      website
      urn
      number_of_pupils
      floor_area
      percentage_free_school_meals
      indicated_has_solar_panels
      indicated_has_storage_heaters
      has_swimming_pool
      serves_dinners
      cooks_dinners_onsite
      cooks_dinners_for_other_schools
      cooks_dinners_for_other_schools_count
      enable_targets_feature
      public
      chart_preference
      funder_id
    ]
    allowed += School::HEATING_TYPES.map { |type| :"heating_#{type}" }
    params.require(:school).permit(*allowed, key_stage_ids: [])
  end
end
