# frozen_string_literal: true

module Schools
  class ManualReadingsService
    # need 13 months for comparisons and 24 months for longterm monthly consumption table
    MONTHS_REQUIRED = 24.months

    attr_reader :target

    def initialize(school, existing_readings = [])
      @school = school
      @existing_readings = existing_readings
      @fuel_types = %i[electricity gas]
      @readings = {}
    end

    # similar to calculate_required but faster to only use DB
    def show_on_menu?
      @school.manual_readings.any? ||
        @school.configuration.aggregate_meter_dates.empty? ||
        @fuel_types.map { |fuel_type| @school.configuration.meter_dates(fuel_type) }
                   .reject(&:empty?)
                   .any? { |dates| dates[:start_date] > MONTHS_REQUIRED.ago || dates[:end_date] < 2.months.ago }
    end

    def calculate_required(aggregate_school)
      calculate_required_when_target if target?
      required_months_and_fuel_types do |month, fuel_type|
        consumption, consumption_missing = calculate_month_consumption(aggregate_school, month, fuel_type)
        add_reading(month, fuel_type, consumption_missing, consumption)
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
      @readings.transform_values do |readings|
        readings.transform_values do |reading_hash|
          reading_hash[:reading]
        end
      end
    end

    def target?
      @target = @school.most_recent_target
      @target.present?
    end

    private

    def required_months_and_fuel_types
      required_months.each do |month|
        @fuel_types.each do |fuel_type|
          next if fuel_type == :gas && !(@school.configuration.fuel_type?(:gas) || @school.heating_gas)
          next unless @readings.dig(month, fuel_type).nil?

          yield month, fuel_type
        end
      end
    end

    def required_months
      (@existing_readings.map(&:month) |
      DateService.start_of_months(MONTHS_REQUIRED.ago, Date.current.prev_month).to_a).sort
    end

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
