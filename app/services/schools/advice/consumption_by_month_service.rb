# frozen_string_literal: true

module Schools
  module Advice
    module ConsumptionByMonthService
      def self.consumption_by_month(aggregate_meter)
        end_date = aggregate_meter&.amr_data&.end_date
        return if end_date.nil?

        DateService.start_of_months(end_date.prev_year.next_month, end_date).to_h do |date|
          current = calculate_month_consumption(aggregate_meter.amr_data, date)
          previous = calculate_month_consumption(aggregate_meter.amr_data, date.prev_year)
          [date.month, { current:, previous:, change: calculate_change(current, previous) }]
        end
      end

      private_class_method def self.sum_or_nil(array)
        array.sum unless array.empty?
      end

      private_class_method def self.calculate_month_consumption(amr_data, beginning_of_month)
        days = beginning_of_month.all_month.map do |date|
          %i[kwh £ co2].freeze.map { |type| amr_data.one_day_kwh(date, type) if amr_data.date_exists?(date)}
        end
        { kwh: sum_or_nil(days.filter_map(&:first)),
          £: sum_or_nil(days.filter_map(&:second)),
          co2: sum_or_nil(days.filter_map(&:third)),
          missing: days.map(&:first).include?(nil) }
      end

      private_class_method def self.calculate_change(current_hash, previous_hash)
        %i[kwh £ co2].to_h do |type|
          current = current_hash[type]
          previous = previous_hash[type]
          [type, unless [current, previous].any?(&:nil?) || current.zero? || current_hash[:missing] || previous_hash[:missing]
                   (current - previous) / current
                 end]
        end
      end
    end
  end
end
