# frozen_string_literal: true

module Schools
  class SchoolTargetsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :school_target, through: :school

    include SchoolAggregation
    include SchoolProgress
    include DashboardTimeline

    before_action :redirect_if_disabled
    before_action :load_advice_pages
    before_action :set_breadcrumbs

    def index
      if @school.has_target? && !@school.most_recent_target.expired?
        @school_target = @school.most_recent_target
        edit
      else
        new
      end
    end

    def show
      edit
    end

    # create first or new target if current has expired
    def new
      if @school.has_current_target?
        redirect_to school_school_targets_path(@school)
      elsif @school.school_targets.any?(&:persisted?)
        @previous_school_target = @school.most_recent_target
        @school_target = target_service.build_target
        render :new, layout: 'dashboards'
      else
        @school_target = target_service.build_target
        render :first, layout: 'dashboards'
      end
    end

    def edit
      authorize! :edit, @school_target
      if @school_target.expired?
        redirect_to new_school_school_target_path(@school),
                    notice: t('schools.school_targets.edit.cannot_update_expired')
      else
        target_service.refresh_target(@school_target)
        @prompt_to_review_target = prompt_to_review_target?
        @fuel_types_changed = fuel_types_changed
        render :edit, layout: 'dashboards'
      end
    end

    def create
      authorize! :create, @school_target
      if @school_target.save
        previous_changes = @school_target.previous_changes.keys
        update_monthly_consumption
        redirect_to redirect_path(previous_changes), notice: t('schools.school_targets.successfully_created')
      elsif @school.has_target?
        render :new
      else
        render :first
      end
    end

    def update
      authorize! :update, @school_target
      if @school_target.update(school_target_params.merge({ revised_fuel_types: [] }))
        # debugger
        previous_changes = @school_target.previous_changes.keys
        update_monthly_consumption
        AggregateSchoolService.new(@school).invalidate_cache
        redirect_to redirect_path(previous_changes), notice: t('schools.school_targets.successfully_updated')
      else
        target_service
        render :edit, layout: 'dashboards'
      end
    end

    def destroy
      authorize! :destroy, @school_target
      @school_target.destroy
      redirect_to school_path(@school), notice: 'Target successfully removed'
    end

    def self.breadcrumb(_current_user)
      I18n.t('advice_pages.nav.manage_targets')
    end

    private

    def set_breadcrumbs
      @breadcrumbs = [{ name: self.class.breadcrumb(current_user) }]
    end

    def load_advice_pages
      @advice_pages = AdvicePage.all
    end

    def update_monthly_consumption
      Targets::GenerateProgressService.new(@school, aggregate_school).update_monthly_consumption(@school_target)
    end

    def redirect_path(previous_changes)
      if previous_changes.include?('electricity') && previous_changes.exclude?('gas')
        school_advice_electricity_target_path(@school)
      elsif previous_changes.include?('gas') && previous_changes.exclude?('electricity')
        school_advice_gas_target_path(@school)
      else
        school_advice_path(@school)
      end
    end

    def school_target_params
      params.require(:school_target).permit(:electricity, :gas, :storage_heater, :start_date, :target_date, :school_id)
    end
  end
end
