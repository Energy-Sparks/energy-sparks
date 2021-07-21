module Schools
  class SchoolTargetsController < ApplicationController
    load_and_authorize_resource :school

    #TODO
    #confirmation pages / notices
    #error messages on forms
    #access control, e.g. edit targets, load_and_authorize
    #only showing relevant targets
    #when revising targets, set defaults based on most recent
    #create service?

    #prompt user to set first target
    def index
      if @school.has_current_target?
        redirect_to school_school_target_path(@school, @school.current_target)
      else
        redirect_to new_school_school_target_path(@school)
      end
    end

    #show the current target
    #summarise the current target, with links to progress and edit
    def show
      @target = @school.has_current_target? ? @school.current_target : @school.most_recent_target
    end

    #create first or new target if current has expired
    def new
      if @school.has_current_target?
        redirect_to school_school_target_path(@school, @school.current_target)
      elsif @school.has_target?
        @most_recent_target = @school.most_recent_target
        @target = create_target
        render :new
      else
        @target = create_target
        render :first
      end
    end

    #update and redirect to show
    def create
      @target = create_target
      if @target.update(school_target_params)
        redirect_to school_school_target_path(@school, @target)
      elsif @school.has_target?
        render :edit
      else
        render :first
      end
    end

    #edit the current target
    def edit
      @target = @school.school_targets.find(params[:id])
    end

    #update and redirect to show
    def update
      @target = @school.school_targets.find(params[:id])
      if @target.update(school_target_params)
        redirect_to school_school_target_path(@school, @target)
      else
        render :edit
      end
    end

    private

    def create_target
      @school.school_targets.new(
        school: @school,
        start_date: Time.zone.today.beginning_of_month,
        target_date: Time.zone.today.beginning_of_month.next_year,
        electricity: 5.0,
        gas: 5.0,
        storage_heaters: 5.0
      )
    end

    def school_target_params
      params.require(:school_target).permit(:electricity, :gas, :storage_heaters)
    end
  end
end
