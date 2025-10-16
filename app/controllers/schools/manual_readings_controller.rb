# frozen_string_literal: true

module Schools
  class ManualReadingsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school

    before_action :set_breadcrumbs

    def show
      @meter_start_dates = %i[electricity gas].select { |fuel_type| @school.configuration.fuel_type?(fuel_type) }
                                              .index_with do |fuel_type|
        @school.configuration.meter_start_date(fuel_type)
      end
      return if @meter_start_dates.empty?

      build_manual_readings
      @readings = @school.manual_readings.sort_by(&:month)
    end

    def update
      if @school.update(resource_params)
        redirect_to school_manual_readings_path(@school), notice: t('common.saved')
      else
        show
        render :show
      end
    end

    private

    def build_manual_readings
      end_date = @meter_start_dates.values.compact.max || Date.current
      return if end_date < 1.year.ago

      start_date = @school.current_target&.start_date&.prev_year || 13.months.ago
      build_missing_readings(start_date, end_date)
    end

    def build_missing_readings(start_date, end_date)
      existing_months = @school.manual_readings.map(&:month)
      DateService.start_of_months(start_date, end_date).each do |month|
        @school.manual_readings.build(month: month) unless existing_months.include?(month)
      end
    end

    def set_breadcrumbs
      @breadcrumbs = [{ name: I18n.t('manage_school_menu.manage_manual_readings') }]
    end

    def resource_params
      params.require(:school).permit(manual_readings_attributes: %i[month electricity gas id _destroy])
    end

    def show_fuel_input(fuel_type, month)
      month && @meter_start_dates.key?(fuel_type) &&
        (@meter_start_dates[fuel_type].nil? || month < @meter_start_dates[fuel_type])
    end
    helper_method :show_fuel_input
  end
end
