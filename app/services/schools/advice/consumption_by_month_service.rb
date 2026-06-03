# frozen_string_literal: true

module Schools
  module Advice
    module ConsumptionByMonthService
      def self.consumption_by_month(aggregate_school, school, fuel_type)
        amr_data = amr_data_for(aggregate_school, fuel_type)
        end_date = end_date_for_with_amr_data(amr_data)
        DateService.start_of_months(end_date.prev_year.next_month, end_date).to_h do |date|
          current = calculate_month_consumption(amr_data, fuel_type, school, date)
          previous = calculate_month_consumption(amr_data, fuel_type, school, date.prev_year)
          [date, { current:, previous:, change: calculate_change(current, previous) }]
        end
      end

      def self.end_date_for(aggregate_school, fuel_type)
        end_date_for_with_amr_data(amr_data_for(aggregate_school, fuel_type))
      end

      private_class_method def self.end_date_for_with_amr_data(amr_data)
        amr_data&.end_date || Date.current
      end

      private_class_method def self.amr_data_for(aggregate_school, fuel_type)
        aggregate_school.aggregate_meter(fuel_type)&.amr_data
      end

      private_class_method def self.sum_or_nil(array)
        array.sum unless array.empty?
      end

      private_class_method def self.calculate_month_consumption(amr_data, fuel_type, school, month)
        consumption = calculate_amr_data_monthly_consumption(amr_data, month)
        if consumption[:missing]
          manual_consumption = school.manual_readings.find_by(month:)&.[](fuel_type)
          if manual_consumption
            consumption.merge!(kwh: manual_consumption,
                               co2: calculate_co2(month, fuel_type, manual_consumption),
                               gbp: nil,
                               manual: true,
                               missing: false)
          end
        end
        consumption
      end

      TYPES = %i[kwh gbp co2].freeze

      private_class_method def self.calculate_amr_data_monthly_consumption(amr_data, month)
        missing = false
        consumption = TYPES.to_h do |type|
          values = month.all_month.filter_map do |date|
            if amr_data&.date_exists?(date)
              amr_data.one_day_kwh(date, type)
            elsif type == :kwh
              missing = true
              nil
            end
          end
          [type, sum_or_nil(values)]
        end
        consumption.merge(missing:)
      end

      private_class_method def self.calculate_change(current_hash, previous_hash)
        TYPES.to_h do |type|
          current = current_hash[type]
          previous = previous_hash[type]
          [type, unless [current, previous].any?(&:nil?) ||
                        previous.zero? || current_hash[:missing] || previous_hash[:missing]
                   (current - previous) / previous
                 end]
        end
      end

      private_class_method def self.calculate_co2(month, fuel_type, consumption)
        SecrCo2Equivalence.co2e_co2(month.year)[fuel_type] * consumption
      end
    end
  end
end
