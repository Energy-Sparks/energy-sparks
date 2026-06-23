# frozen_string_literal: true

module Schools
  class UtilityStatusComponent < ApplicationComponent
    def initialize(school:, **)
      super(**)
      @school = school
    end

    def render?
      @school.process_data && @school.configuration.present?
    end

    private

    def utility_status
      return ['text-bg-danger', 'Not data visible'] unless @school.data_enabled
      return ['text-bg-danger', 'No data'] if fuel_status.empty?

      if fuel_status.values.all?(false)
        ['text-bg-danger', 'No recent data']
      elsif fuel_status.values.all?(true)
        ['text-bg-success', 'All utilities']
      elsif fuel_status.values.any?(true)
        ['text-bg-warning', 'One utility']
      end
    end

    def fuel_status
      @fuel_status ||= @school.configuration.aggregate_meter_dates.transform_values do |dates|
        Date.parse(dates['end_date']) > 14.days.ago
      end
    end
  end
end
