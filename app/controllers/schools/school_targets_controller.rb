module Schools
  class SchoolTargetsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :school_target, via: :school

    include SchoolAggregation
    include SchoolProgress

    before_action :calculate_current_progress, only: :show

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
        @previous_school_target = @school.most_recent_target
        @school_target = create_target(@previous_school_target)
        render :new
      else
        @school_target = create_target
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
    end

    def update
      if @school_target.update(school_target_params)
        redirect_to school_school_target_path(@school, @school_target), notice: 'Target successfully updated'
      else
        render :edit
      end
    end

    private

    def create_target(previous = nil)
      if previous.present?
        @school.school_targets.build(
          start_date: Time.zone.today.beginning_of_month,
          target_date: Time.zone.today.beginning_of_month.next_year,
          electricity: previous.electricity,
          gas: previous.gas,
          storage_heaters: previous.storage_heaters
        )
      else
        @school.school_targets.build(
          start_date: Time.zone.today.beginning_of_month,
          target_date: Time.zone.today.beginning_of_month.next_year,
          electricity: 5.0,
          gas: 5.0,
          storage_heaters: 5.0
        )
      end
    end

    def school_target_params
      params.require(:school_target).permit(:electricity, :gas, :storage_heaters, :start_date, :target_date, :school_id)
    end
  end
end
