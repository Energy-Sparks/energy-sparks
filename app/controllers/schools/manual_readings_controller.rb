# frozen_string_literal: true

module Schools
  class ManualReadingsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school

    before_action :set_breadcrumbs

    include SchoolProgress

    def show
      @current_target = @school.current_target
      target = @current_target || target_service.build_target
      @months = %i[electricity gas].select { |fuel_type| @school.configuration.fuel_type?(fuel_type) }
                                   .to_h do |fuel_type|
        start_date = target.start_date.prev_year.beginning_of_month
        end_date = @school.configuration.meter_start_date(fuel_type)
        [fuel_type, DateService.start_of_months(start_date, end_date).to_a]
      end
      existing_months = @school.manual_readings.pluck(:month)
      @months.values.flatten.uniq.each do |month|
        @school.manual_readings.build(month:) unless existing_months.include?(month)
      end
      @readings = @school.manual_readings.sort_by(&:month)
    end

    def update
      @school.update(resource_params)
      if @school.save
        redirect_to school_manual_readings_path(@school), notice: t('common.saved')
      else
        render :show
      end
    end

    private

    def set_breadcrumbs
      @breadcrumbs = [{ name: I18n.t('manage_school_menu.manage_manual_readings') }]
    end

    def resource_params
      params.require(:school).permit(manual_readings_attributes: %i[month electricity gas id])
    end
  end
end
