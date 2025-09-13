module SchoolGroups
  module Advice
    class HeatingControlController < BaseAdviceWithComparisonController
      def insights
        @comparison = SchoolGroups::CategoriseSchools.new(schools: @schools).categorise_schools_for_advice_page(@advice_page)
        @insight_table_headers = insight_table_headers
      end

      def analysis
        alert_type = AlertType.find_by_class_name('AlertSeasonalHeatingSchoolDays')
        @alerts = alert_type ? SchoolGroups::Alerts.new(@schools).alerts(alert_type) : []
        @categorised_savings = SchoolGroups::CategoriseSchools.new(schools: @schools).categorise_savings(@advice_page, @alerts)
        @report_headers = Comparison::HeatingInWarmWeather.default_headers
        @warm_day_temperature = AnalyseHeatingAndHotWater::HeatingModelTemperatureSpace::BALANCE_POINT_TEMPERATURE
      end

      private

      def insight_table_headers
        [
          t('analytics.benchmarking.configuration.column_headings.school'),
          t('analytics.benchmarking.configuration.column_headings.percentage_of_annual_heating_consumed_in_warm_weather'),
        ]
      end

      def advice_page_key
        :heating_control
      end

      def report_key
        :heating_in_warm_weather
      end

      def load_data
        Comparison::HeatingInWarmWeather.for_schools(@schools).with_data.sort_default
      end
    end
  end
end
