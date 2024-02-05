module Schools
  class EstimatedAnnualConsumptionsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :estimated_annual_consumption, through: :school

    before_action :set_breadcrumbs

    def index
      if @school.estimated_annual_consumptions.any?
        redirect_to edit_school_estimated_annual_consumption_path(@school, @school.latest_annual_estimate)
      elsif @school.suggest_annual_estimate?
        redirect_to new_school_estimated_annual_consumption_path(@school)
      else
        # no estimate and no need, then redirect
        redirect_to school_path(@school)
      end
    end

    def new
      if @school.latest_annual_estimate.present?
        redirect_to edit_school_estimated_annual_consumption_path(@school, @school.latest_annual_estimate)
      else
        render :new
      end
    end

    def create
      authorize! :create, @estimated_annual_consumption
      if @estimated_annual_consumption.save
        redirect_to edit_school_estimated_annual_consumption_path(@school, @estimated_annual_consumption, updated: true)
      else
        render :new
      end
    end

    def edit
      authorize! :edit, @estimated_annual_consumption
    end

    def update
      authorize! :update, @estimated_annual_consumption
      if @estimated_annual_consumption.update(estimated_annual_consumption_params)
        redirect_to edit_school_estimated_annual_consumption_path(@school, @estimated_annual_consumption, updated: true)
      else
        render :edit
      end
    end

    def destroy
      authorize! :delete, @estimated_annual_consumption
      @estimated_annual_consumption.destroy
      redirect_to school_path(@school), notice: I18n.t('schools.estimated_annual_consumptions.destroy.estimate_successfully_removed')
    end

    private

    def set_breadcrumbs
      @breadcrumbs = [{ name: I18n.t('schools.estimated_annual_consumptions.breadcrumb') }]
    end

    def estimated_annual_consumption_params
      params.require(:estimated_annual_consumption).permit(:electricity, :gas, :storage_heaters, :year, :school_id)
    end
  end
end
