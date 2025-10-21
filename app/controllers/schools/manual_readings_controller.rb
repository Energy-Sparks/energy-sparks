# frozen_string_literal: true

module Schools
  class ManualReadingsController < ApplicationController
    include SchoolAggregation

    load_and_authorize_resource :school
    load_and_authorize_resource through: :school

    before_action :check_aggregated_school_in_cache
    before_action :set_breadcrumbs

    def show
      @missing = build_manual_readings_and_missing(@school)
      @fuel_types = @missing.map(&:second).uniq
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

    # Creates manual reading objects on the school, either blank for input or with data for display.
    # @param school to add manual readings to
    # @return [[month, fuel_type], ...] months and fuel types missing data
    def build_manual_readings_and_missing(school)
      missing, to_build = calculate_required_manual_readings
      existing_months = school.manual_readings.map(&:month)
      to_build.each do |month, consumption|
        if existing_months.exclude?(month) && month < Date.current.beginning_of_month && missing.present?
          school.manual_readings.build(month:, **round_consumption(consumption))
        end
      end
      missing
    end

    def calculate_required_manual_readings
      fuel_types = %i[electricity gas]
      missing = []
      to_build = {}
      target = @school.most_recent_target
      if target
        fuel_types.each do |fuel_type|
          (target.monthly_consumption(fuel_type) || []).each do |consumption|
            month = Date.new(consumption[:year], consumption[:month])
            (to_build[month] ||= {})[fuel_type] = if consumption[:current_missing]
                                                    missing << [month, fuel_type]
                                                    nil
                                                  else
                                                    consumption[:current_consumption]
                                                  end
            previous_month = month.prev_year
            missing << [previous_month, fuel_type] if consumption[:previous_missing]
            (to_build[previous_month] ||= {})[fuel_type] = consumption[:previous_consumption]
          end
        end
      else
        fuel_types.delete(:gas) unless @school.configuration.fuel_type?(:gas) || @school.heating_gas
        # get 13 months for comparisons
        DateService.start_of_months(13.months.ago, Date.current.prev_month).each do |month|
          fuel_types.each do |fuel_type|
            consumption, consumption_missing = calculate_month_consumption(month, fuel_type)
            (to_build[month] ||= {})[fuel_type] = consumption_missing ? nil : consumption
            missing << [month, fuel_type] if consumption_missing
          end
        end
      end
      [missing, to_build]
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
      params.require(:school).permit(manual_readings_attributes: %i[month electricity gas id _destroy])
    end

    def show_fuel_input(fuel_type, month)
      month && @missing.include?.key?(fuel_type) &&
        (@meter_start_dates[fuel_type].nil? || month < @meter_start_dates[fuel_type])
    end
    helper_method :show_fuel_input
  end
end
