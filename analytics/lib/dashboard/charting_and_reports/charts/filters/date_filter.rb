# frozen_string_literal: true

module Charts
  module Filters
    # Supporting for filtering out dates from a calculation based on the chart configuration
    class DateFilter < Base

      def match_filter_by_day(date)
        # heating_daytype filter gets filtered out post aggregation, reduced performance but simpler
        return true unless @chart_config.chart_has_filter?
        return true if @chart_config.heating_daytype_filter?
        return true if @chart_config.submeter_filter?

        match_daytype = match_occupied_type_filter_by_day(date) if @chart_config.daytype_filter?
        match_heating = true
        match_heating = match_filter_by_heatingdayday(date) if @chart_config.heating_filter?
        match_model = true
        match_model = match_filter_by_model_type(date) if @chart_config.model_type_filter?
        match_daytype && match_heating && match_model
      end

      private

      def match_filter_by_heatingdayday(date)
        @chart_config.heating_filter == @results.series_manager.heating_model.heating_on?(date)
      end

      def match_filter_by_model_type(date)
        model_list = @chart_config.model_type_filters
        model_list = [model_list] if model_list.is_a?(Symbol) # convert to array if not an array
        model_list.include?(@results.series_manager.heating_model.model_type?(date))
      end

      def match_occupied_type_filter_by_day(date)
        filter = @chart_config.day_type_filter
        holidays = @school.holidays
        match = false
        [filter].flatten.each do |one_filter|
          case one_filter
          when Series::DayType::HOLIDAY
            match ||= true if holidays.holiday?(date)
          when Series::DayType::WEEKEND
            match ||= true if DateTimeHelper.weekend?(date) && !holidays.holiday?(date)
          when Series::DayType::SCHOOLDAYOPEN, Series::DayType::SCHOOLDAYCLOSED
            match ||= true unless DateTimeHelper.weekend?(date) || holidays.holiday?(date)
          end
        end
        match
      end

    end
  end
end
