# frozen_string_literal: true

module Schools
  module Advice
    module ConsumptionByMonthService
      def self.consumption_by_month(aggregate_meter, school)
        end_date = aggregate_meter&.amr_data&.end_date || Date.current
        DateService.start_of_months(end_date.prev_year.next_month, end_date).to_h do |date|
          current = calculate_month_consumption(aggregate_meter, school, date)
          previous = calculate_month_consumption(aggregate_meter, school, date.prev_year)
          [date, { current:, previous:, change: calculate_change(current, previous) }]
        end
      end

      private_class_method def self.sum_or_nil(array)
        array.sum unless array.empty?
      end

      private_class_method def self.calculate_month_consumption(aggregate_meter, school, month)
        consumption = calculate_amr_data_monthly_consumption(aggregate_meter.amr_data, month)
        if consumption[:missing]
          manual_consumption = school.manual_readings.find_by(month:)&.[](aggregate_meter.fuel_type)
          if manual_consumption
            consumption.merge!(kwh: manual_consumption,
                               co2: calculate_co2(manual_consumption, aggregate_meter.fuel_type),
                               gbp: nil,
                               manual: true,
                               missing: false)
          end
        end
        consumption
      end

      TYPES = %i[kwh gbp co2].freeze

      private_class_method def self.calculate_amr_data_monthly_consumption(amr_data, month)
        days = month.all_month.map do |date|
          TYPES.map { |type| amr_data.one_day_kwh(date, type) if amr_data.date_exists?(date) }
        end
        consumption = TYPES.each_with_index.to_h do |type, i|
          [type, sum_or_nil(days.filter_map { |day| day[i] })]
        end
        consumption[:missing] = days.map(&:first).include?(nil)
        consumption
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

      private_class_method def self.calculate_co2(consumption, fuel_type)
        EnergyEquivalences.co2_kg_kwh(fuel_type) * consumption
      end
    end
  end
end
