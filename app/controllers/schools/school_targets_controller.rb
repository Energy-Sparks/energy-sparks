module Schools
  class SchoolTargetsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :school_target, via: :school

    #TODO
    #error messages on forms
    #confirmation pages / notices
    #only showing relevant targets
    #create service
    #when revising targets, set defaults based on most recent

    def index
      if @school.has_current_target?
        redirect_to school_school_target_path(@school, @school.current_target)
      else
        redirect_to new_school_school_target_path(@school)
      end
    end

    def show
    end

    #create first or new target if current has expired
    def new
      if @school.has_current_target?
        redirect_to school_school_target_path(@school, @school.current_target)
      elsif @school.has_target?
        @school_target = create_target
        @most_recent_target = @school.most_recent_target
        render :new
      else
        @school_target = create_target
        render :first
      end
    end

    def create
      @school_target = create_target
      if @school_target.update(school_target_params)
        redirect_to school_school_target_path(@school, @school_target)
      elsif @school.has_target?
        render :edit
      else
        render :first
      end
    end

    def edit
    end

    def update
      if @school_target.update(school_target_params)
        redirect_to school_school_target_path(@school, @school_target)
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
