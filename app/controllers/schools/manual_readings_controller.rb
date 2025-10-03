# frozen_string_literal: true

module Schools
  class ManualReadingsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school

    before_action :set_breadcrumbs

    def show
      @meter_start_dates = %i[electricity gas].index_with do |fuel_type|
        @school.configuration.meter_start_date(fuel_type)
      end
      end_date = @meter_start_dates.values.max
      return if end_date < 1.year.ago

      start_date = @school.current_target&.start_date&.prev_year || (end_date - 13.months)
      existing_months = @school.manual_readings.pluck(:month)
      DateService.start_of_months(start_date, end_date).each do |month|
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
      params.require(:school).permit(manual_readings_attributes: %i[month electricity gas id _destroy])
    end

    def show_fuel_input(fuel_type, month)
      month && @meter_start_dates[fuel_type] && month < @meter_start_dates[fuel_type]
    end
    helper_method :show_fuel_input
  end
end
