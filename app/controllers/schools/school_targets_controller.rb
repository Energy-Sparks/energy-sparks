module Schools
  class SchoolTargetsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :school_target, via: :school

    include SchoolAggregation
    include SchoolProgress
    include ActivityTypeFilterable

    before_action :check_aggregated_school_in_cache, only: :show
    before_action :redirect_if_disabled
    before_action :calculate_current_progress, only: :show

    def index
      if @school.has_current_target?
        redirect_to school_school_target_path(@school, @school.current_target)
      else
        redirect_to new_school_school_target_path(@school)
      end
    end

    def show
      setup_activity_suggestions
      @progress_service = progress_service
      @prompt_to_review_target = prompt_to_review_target?
      @fuel_types_changed = fuel_types_changed
    end

    #create first or new target if current has expired
    def new
      if @school.has_current_target?
        redirect_to school_school_target_path(@school, @school.current_target)
      elsif @school.has_target?
        @previous_school_target = @school.most_recent_target
        @school_target = target_service.build_target
        render :new
      else
        @school_target = target_service.build_target
        render :first
      end
    end

    def create
      if @school_target.save
        redirect_to school_school_target_path(@school, @school_target), notice: 'Target successfully created'
      elsif @school.has_target?
        render :new
      else
        render :first
      end
    end

    def edit
      target_service.refresh_target(@school_target)
      @prompt_to_review_target = prompt_to_review_target?
      @fuel_types_changed = fuel_types_changed
    end

    def update
      if @school_target.update(school_target_params.merge({ revised_fuel_types: [] }))
        AggregateSchoolService.new(@school).invalidate_cache
        redirect_to school_school_target_path(@school, @school_target), notice: 'Target successfully updated'
      else
        target_service
        render :edit
      end
    end

    private

    def school_target_params
      params.require(:school_target).permit(:electricity, :gas, :storage_heaters, :start_date, :target_date, :school_id)
    end

    def setup_activity_suggestions
      suggester = NextActivitySuggesterWithFilter.new(@school, activity_type_filter)
      @suggestions = suggester.suggest_for_school_targets
    end
  end
end
