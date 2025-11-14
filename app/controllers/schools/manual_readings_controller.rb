# frozen_string_literal: true

module Schools
  class ManualReadingsController < ApplicationController
    include SchoolAggregation

    load_and_authorize_resource :school
    load_and_authorize_resource through: :school

    before_action :check_aggregated_school_in_cache
    before_action :set_breadcrumbs

    def show
      existing_readings = @school.manual_readings.to_a
      @readings = Schools::ManualReadingsService.new(@school, existing_readings)
      @readings.calculate_required(aggregate_school)
      build_manual_readings(@school, existing_readings, @readings)
    end

    def update
      params_hash = resource_params.to_h
      params_hash['manual_readings_attributes'].each_value do |parameters|
        parameters['_destroy'] = '1' if parameters['id'] && parameters['gas'].blank? && parameters['electricity'].blank?
      end
      if @school.update(params_hash)
        readings = Schools::ManualReadingsService.new(@school)
        if readings.target?
          Targets::GenerateProgressService.new(@school, aggregate_school).update_monthly_consumption(readings.target)
        end
        redirect_to school_manual_readings_path(@school), notice: t('common.saved')
      else
        show
        render :show
      end
    end

    private

    # Creates manual reading objects on the school, either blank for input or with data for display.
    # @param school to add manual readings to
    # @param readings [Hash] readings to show by month
    def build_manual_readings(school, existing_readings, service)
      return if service.all_required_readings_disabled?

      service.readings.each do |month, readings|
        consumption = round_consumption(readings)
        existing_reading = existing_readings.find { |reading| reading.month == month }
        if existing_reading
          existing_reading.assign_attributes(consumption)
        else
          school.manual_readings.build(month:, **consumption)
        end
      end
    end

    def round_consumption(consumption)
      consumption.transform_values { |consumption| consumption&.round(1) }
    end

    def set_breadcrumbs
      @breadcrumbs = [{ name: I18n.t('manage_school_menu.manage_manual_readings') }]
    end

    def resource_params
      params.require(:school).permit(manual_readings_attributes: %i[month electricity gas id])
    end

    def show_fuel_input(fuel_type, month)
      month && @missing.include?.key?(fuel_type) &&
        (@meter_start_dates[fuel_type].nil? || month < @meter_start_dates[fuel_type])
    end
    helper_method :show_fuel_input
  end
end
