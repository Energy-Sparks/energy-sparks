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
      @readings, @fuel_types = calculate_required_manual_readings(existing_readings)
      build_manual_readings(@school, existing_readings, @readings)
    end

    def update
      params_hash = resource_params.to_h
      params_hash['manual_readings_attributes'].each_value do |parameters|
        parameters['_destroy'] = '1' if parameters['id'] && parameters['gas'].blank? && parameters['electricity'].blank?
      end
      if @school.update(params_hash)
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
    def build_manual_readings(school, existing_readings, readings)
      return unless readings.values.flat_map(&:values).any? { |h| !h[:disabled] }

      readings.each do |month, missing_and_reading|
        consumption = round_consumption(missing_and_reading.transform_values { |hash| hash[:reading] })
        existing_reading = existing_readings.find { |reading| reading.month == month }
        if existing_reading
          existing_reading.assign_attributes(consumption)
        else
          school.manual_readings.build(month:, **consumption)
        end
      end
    end

    def calculate_required_manual_readings(existing_readings)
      fuel_types = %i[electricity gas]
      readings = {}
      target = @school.most_recent_target
      if target
        fuel_types.each do |fuel_type|
          consumption = target.monthly_consumption(fuel_type)
          fuel_types.delete(fuel_type) and next if consumption.nil?

          consumption.each do |consumption|
            month = Date.new(consumption[:year], consumption[:month])
            add_reading(readings, existing_readings, month, fuel_type,
                        consumption[:current_missing], consumption[:current_consumption])
            add_reading(readings, existing_readings, month.prev_year, fuel_type,
                        consumption[:previous_missing], consumption[:previous_consumption])
          end
        end
      else
        fuel_types.delete(:gas) unless @school.configuration.fuel_type?(:gas) || @school.heating_gas
        # get 13 months for comparisons
        DateService.start_of_months(13.months.ago, Date.current.prev_month).each do |month|
          fuel_types.each do |fuel_type|
            consumption, consumption_missing = calculate_month_consumption(month, fuel_type)
            add_reading(readings, existing_readings, month, fuel_type, consumption_missing, consumption)
          end
        end
      end
      [readings, fuel_types]
    end

    def add_reading(readings, existing_readings, month, fuel_type, missing, reading)
      return if month >= Date.current.beginning_of_month

      existing_reading = existing_readings.find { |reading| reading.month == month }
      disabled, reading = if existing_reading&.[](fuel_type).present?
                            [false, existing_reading[fuel_type]]
                          else
                            [!missing, missing ? nil : reading]
                          end
      (readings[month] ||= {})[fuel_type] = { disabled:, reading: }
    end

    def round_consumption(consumption)
      consumption.transform_values { |consumption| consumption&.round(1) }
    end

    def calculate_month_consumption(month, fuel_type)
      amr_data = aggregate_school.aggregate_meter(fuel_type)&.amr_data
      kwhs = month.all_month.map { |date| amr_data&.[](date)&.one_day_kwh }
      [kwhs.compact.sum, kwhs.include?(nil)]
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
