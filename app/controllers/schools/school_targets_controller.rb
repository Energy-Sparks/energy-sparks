module Schools
  class SchoolTargetsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :school_target, through: :school

    include SchoolAggregation
    include SchoolProgress
    include DashboardTimeline

    skip_before_action :authenticate_user!, only: [:index, :show]

    before_action :check_aggregated_school_in_cache, only: :show
    before_action :redirect_if_disabled
    before_action :set_breadcrumbs

    def index
      if @school.has_target?
        redirect_to school_school_target_path(@school, @school.most_recent_target)
      else
        redirect_to new_school_school_target_path(@school)
      end
    end

    def show
      authorize! :show, @school_target

      unless @school_target.report_last_generated.nil?
        @progress_summary = @school_target.to_progress_summary
        @overview_data = Schools::ManagementTableService.new(@school).management_data
      end

      if @school_target.current?
        @activities = Recommendations::Activities.new(@school).based_on_energy_use
        @actions = Recommendations::Actions.new(@school).based_on_energy_use
        # list of fuel types to suggest estimates
        @suggest_estimates_for_fuel_types = suggest_estimates_for_fuel_types(check_data: true)
        @prompt_to_review_target = prompt_to_review_target?
        @fuel_types_changed = fuel_types_changed
        render :current
      else
        @observations = setup_target_timeline(@school_target)
        render :expired
      end
    end

    # create first or new target if current has expired
    def new
      if @school.has_current_target?
        redirect_to school_school_target_path(@school, @school.current_target)
      elsif @school.school_targets.any?(&:persisted?)
        @previous_school_target = @school.most_recent_target
        @school_target = target_service.build_target
        render :new
      else
        @school_target = target_service.build_target
        render :first
      end
    end

    def create
      authorize! :create, @school_target
      if @school_target.save
        redirect_to school_school_target_path(@school, @school_target), notice: 'Target successfully created'
      elsif @school.has_target?
        render :new
      else
        render :first
      end
    end

    def edit
      authorize! :edit, @school_target
      if @school_target.expired?
        redirect_to school_school_target_path(@school, @school_target), notice: 'Cannot edit an expired target'
      else
        target_service.refresh_target(@school_target)
        @prompt_to_review_target = prompt_to_review_target?
        @fuel_types_changed = fuel_types_changed
      end
    end

    def update
      authorize! :update, @school_target
      if @school_target.update(school_target_params.merge({ revised_fuel_types: [] }))
        AggregateSchoolService.new(@school).invalidate_cache
        redirect_to school_school_target_path(@school, @school_target), notice: 'Target successfully updated'
      else
        target_service
        render :edit
      end
    end

    def destroy
      authorize! :destroy, @school_target
      @school_target.destroy
      redirect_to school_path(@school), notice: 'Target successfully removed'
    end

    private

    def set_breadcrumbs
      @breadcrumbs = [{ name: I18n.t('manage_school_menu.review_targets') }]
    end

    def school_target_params
      params.require(:school_target).permit(:electricity, :gas, :storage_heaters, :start_date, :target_date, :school_id)
    end
  end
end
