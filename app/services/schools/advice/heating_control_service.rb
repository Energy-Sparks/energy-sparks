# frozen_string_literal: true

module Schools
  module Advice
    class HeatingControlService
      include AnalysableMixin

      # number of days heating on in warm weather => rating
      WARM_WEATHER_DAYS_RATING = {
        0..5 => :excellent,
        6..11 => :good,
        12..16 => :above_average,
        17..24 => :poor,
        25..365 => :very_poor
      }.freeze

      EXEMPLAR_WARM_WEATHER_DAYS = 6
      BENCHMARK_WARM_WEATHER_DAYS = 11

      def initialize(school, aggregate_school_service)
        @school = school
        @aggregate_school_service = aggregate_school_service
      end

      delegate :enough_data?, to: :heating_start_time_service

      def multiple_meters?
        meters.count > 1
      end

      def meters
        @meters ||= heat_meters
      end

      # TODO: needs changes in the analytics
      def data_available_from
        nil
      end

      delegate :average_start_time_last_week, to: :heating_start_time_service

      def last_week_start_times
        @last_week_start_times ||= heating_start_time_service.last_week_start_times
      end

      def percentage_of_annual_gas
        @percentage_of_annual_gas ||= heating_savings_service.percentage_of_annual_gas
      end

      def estimated_savings
        @estimated_savings ||= heating_savings_service.estimated_savings
      end

      def seasonal_analysis
        @seasonal_analysis ||= seasonal_analysis_service.seasonal_analysis
      end

      def enough_data_for_seasonal_analysis?
        @enough_data_for_seasonal_analysis ||= seasonal_analysis_service.enough_data?
      end

      def warm_weather_on_days_rating
        WARM_WEATHER_DAYS_RATING.select { |k, _v| k.cover?(days_when_heating_on_warm_weather) }.values.first
      end

      def benchmark_warm_weather_days
        Schools::Comparison.new(
          school_value: days_when_heating_on_warm_weather,
          benchmark_value: BENCHMARK_WARM_WEATHER_DAYS,
          exemplar_value: EXEMPLAR_WARM_WEATHER_DAYS,
          unit: :days
        )
      end

      def heating_on_in_last_weeks_holiday?
        meter_collection.holidays.day_type(Time.zone.today) != :holiday &&
          last_week_start_times.days.any? do |day|
            meter_collection.holidays.day_type(day.date) == :holiday && day.heating_start_time
          end
      end

      private

      def days_when_heating_on_warm_weather
        @days_when_heating_on_warm_weather ||= seasonal_analysis.heating_on_in_warm_weather_days.to_i
      end

      def heat_meters
        meter_collection.heat_meters.reject(&:non_heating_only?).sort_by(&:mpan_mprn)
      end

      def heating_start_time_service
        @heating_start_time_service ||= Heating::HeatingStartTimeService.new(meter_collection, analysis_date)
      end

      def heating_savings_service
        @heating_savings_service ||= Heating::HeatingStartTimeSavingsService.new(meter_collection, analysis_date)
      end

      def seasonal_analysis_service
        @seasonal_analysis_service ||= Heating::SeasonalControlAnalysisService.new(meter_collection: meter_collection)
      end

      def analysis_date
        AggregateSchoolService.analysis_date(meter_collection, :gas)
      end

      def meter_collection
        @aggregate_school_service.meter_collection
      end
    end
  end
end
