# frozen_string_literal: true

module Schools
  class ManualReadingsService
    # need 13 months for comparisons and 24 months for longterm monthly consumption table
    MONTHS_REQUIRED_WHEN_NO_TARGET = 24.months

    attr_reader :target

    def initialize(school, existing_readings = [])
      @school = school
      @existing_readings = existing_readings
      @fuel_types = %i[electricity gas]
      @readings = {}
    end

    # similar to calculate_required but faster to only use DB
    def show_on_menu?
      if @school.manual_readings.any?
        true
      elsif target?
        calculate_required_when_target
        !all_required_readings_disabled?
      else
        @school.configuration.aggregate_meter_dates.empty? ||
          @fuel_types.map { |fuel_type| @school.configuration.meter_dates(fuel_type) }
                     .reject(&:empty?)
                     .any? do |dates|
            dates[:start_date] > MONTHS_REQUIRED_WHEN_NO_TARGET.ago || dates[:end_date] < 2.months.ago
          end
      end
    end

    def calculate_required(aggregate_school)
      if target?
        calculate_required_when_target
      else
        DateService.start_of_months(MONTHS_REQUIRED_WHEN_NO_TARGET.ago, Date.current.prev_month).each do |month|
          @fuel_types.each do |fuel_type|
            next if fuel_type == :gas && !(@school.configuration.fuel_type?(:gas) || @school.heating_gas)

            consumption, consumption_missing = calculate_month_consumption(aggregate_school, month, fuel_type)
            add_reading(month, fuel_type, consumption_missing, consumption)
          end
        end
      end
    end

    def all_required_readings_disabled?
      @readings.values.flat_map(&:values).all? { |h| h[:disabled] }
    end

    def fuel_types
      # make electricity first on form
      @readings.values.flat_map(&:keys).uniq.sort
    end

    def disabled?(month, fuel_type)
      @readings.dig(month, fuel_type, :disabled)
    end

    def readings
      @readings.transform_values do |missing_and_readings|
        missing_and_readings.transform_values do |missing_and_reading|
          missing_and_reading[:reading]
        end
      end
    end

    def target?
      @target = @school.most_recent_target
      @target.present?
    end

    private

    def calculate_required_when_target
      @fuel_types.each do |fuel_type|
        consumption = @target.monthly_consumption(fuel_type)
        next if consumption.nil?

        consumption.each do |consumption|
          month = Date.new(consumption[:year], consumption[:month])
          add_reading(month, fuel_type, consumption[:current_missing], consumption[:current_consumption])
          add_reading(month.prev_year, fuel_type, consumption[:previous_missing], consumption[:previous_consumption])
        end
      end
    end

    def add_reading(month, fuel_type, missing, reading)
      return if month >= Date.current.prev_month.beginning_of_month

      existing_reading = @existing_readings.find { |reading| reading.month == month }
      disabled, reading = if existing_reading&.[](fuel_type).present?
                            [false, existing_reading[fuel_type]]
                          else
                            [!missing, missing ? nil : reading]
                          end
      (@readings[month] ||= {})[fuel_type] = { disabled:, reading: }
    end

    def calculate_month_consumption(aggregate_school, month, fuel_type)
      amr_data = aggregate_school.aggregate_meter(fuel_type)&.amr_data
      kwhs = month.all_month.map { |date| amr_data&.[](date)&.one_day_kwh }
      [kwhs.compact.sum, kwhs.include?(nil)]
    end
  end
end
