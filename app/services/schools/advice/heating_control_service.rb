module Schools
  module Advice
    class HeatingControlService
      include AnalysableMixin

      #number of days heating on in warm weather => rating
      WARM_WEATHER_DAYS_RATING = {
        0..5     => :excellent,
        6..11    => :good,
        12..16   => :above_average,
        17..24   => :poor,
        25..365  => :very_poor
      }.freeze

      EXEMPLAR_WARM_WEATHER_DAYS = 6
      BENCHMARK_WARM_WEATHER_DAYS = 11

      def initialize(school, meter_collection)
        @school = school
        @meter_collection = meter_collection
      end

      def enough_data?
        heating_start_time_service.enough_data?
      end

      def multiple_meters?
        meters.count > 1
      end

      def meters
        excluded_meter_ids = MeterAttribute.where(<<-SQL.squish
                                                      input_data::text IN ('"kitchen_only"', '"hotwater_only"')
        SQL
                                                  ).pluck(:meter_id)

        @school.meters
               .active
               .gas
               .where.not(id: excluded_meter_ids)
      end

      def date_ranges_by_meter
        heat_meters.each_with_object({}) do |analytics_meter, date_range_by_meter|
          end_date = analytics_meter.amr_data.end_date
          start_date = [end_date - 363, analytics_meter.amr_data.start_date].max
          meter = @school.meters.find_by_mpan_mprn(analytics_meter.mpan_mprn)
          date_range_by_meter[analytics_meter.mpan_mprn] = {
            meter: meter,
            start_date: start_date,
            end_date: end_date
          }
        end
      end

      #TODO: needs changes in the analytics
      def data_available_from
        nil
      end

      def average_start_time_last_week
        heating_start_time_service.average_start_time_last_week
      end

      def last_week_start_times
        heating_start_time_service.last_week_start_times
      end

      def percentage_of_annual_gas
        heating_savings_service.percentage_of_annual_gas
      end

      def estimated_savings
        heating_savings_service.estimated_savings
      end

      def seasonal_analysis
        seasonal_analysis_service.seasonal_analysis
      end

      def enough_data_for_seasonal_analysis?
        seasonal_analysis_service.enough_data?
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

      private

      def days_when_heating_on_warm_weather
        seasonal_analysis.heating_on_in_warm_weather_days.to_i
      end

      def heat_meters
        @heat_meters ||= @meter_collection.heat_meters
      end

      def heating_start_time_service
        @heating_start_time_service ||= Heating::HeatingStartTimeService.new(@meter_collection, analysis_date)
      end

      def heating_savings_service
        @heating_savings_service ||= Heating::HeatingStartTimeSavingsService.new(@meter_collection, analysis_date)
      end

      def seasonal_analysis_service
        @seasonal_analysis_service ||= Heating::SeasonalControlAnalysisService.new(meter_collection: @meter_collection)
      end

      def analysis_date
        AggregateSchoolService.analysis_date(@meter_collection, :gas)
      end
    end
  end
end
